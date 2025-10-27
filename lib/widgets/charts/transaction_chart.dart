import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../services/simple_localization.dart';

enum TimePeriod { daily, weekly, monthly, yearly }

/// Widget separado para el contenido del gráfico
class ChartContentWidget extends ConsumerWidget {
  final List<Transaction> transactions;
  final TransactionType type;

  const ChartContentWidget({
    super.key,
    required this.transactions,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = type == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    // Agrupar por categoría según el tipo
    final Map<String, double> categoryAmounts = {};
    for (var transaction in transactions) {
      if (transaction.type == type) {
        categoryAmounts[transaction.category] =
            (categoryAmounts[transaction.category] ?? 0) + transaction.amount;
      }
    }

    // Filtrar categorías con transacciones
    final categoriesWithAmounts = categories
        .where((cat) => categoryAmounts[cat.id] != null)
        .toList();

    if (categoriesWithAmounts.isEmpty) {
      return Center(
        child: Text(
          type == TransactionType.expense
              ? SimpleLocalization.getText(ref, 'noExpenses')
              : SimpleLocalization.getText(ref, 'noIncome'),
        ),
      );
    }

    // Ordenar por monto descendente
    categoriesWithAmounts.sort(
      (a, b) =>
          (categoryAmounts[b.id] ?? 0).compareTo(categoryAmounts[a.id] ?? 0),
    );

    final totalAmounts = categoryAmounts.values.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Gráfico de dona
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 25,
                  sections: _buildCategoryChartSections(
                    categoriesWithAmounts,
                    categoryAmounts,
                    totalAmounts,
                  ),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, response) {},
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Leyenda
          Expanded(
            flex: 1,
            child: _buildCategoryLegend(
              categoriesWithAmounts,
              categoryAmounts,
              totalAmounts,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildCategoryChartSections(
    List<Category> categories,
    Map<String, double> amounts,
    double total,
  ) {
    return categories.take(6).map((category) {
      final amount = amounts[category.id] ?? 0;
      final percentage = (amount / total * 100);

      return PieChartSectionData(
        value: amount,
        title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        color: Color(int.parse(category.color.replaceFirst('#', '0xFF'))),
        radius: 50,
      );
    }).toList();
  }

  Widget _buildCategoryLegend(
    List<Category> categories,
    Map<String, double> amounts,
    double total,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: categories.take(6).length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = categories[index];
        final amount = amounts[category.id] ?? 0;
        final percentage = (amount / total * 100);

        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(
                  int.parse(category.color.replaceFirst('#', '0xFF')),
                ),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class TransactionChart extends ConsumerStatefulWidget {
  const TransactionChart({super.key});

  @override
  ConsumerState<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends ConsumerState<TransactionChart> {
  TimePeriod _selectedPeriod = TimePeriod.monthly;
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.analytics01,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        SimpleLocalization.getText(
                          ref,
                          'distributionByCategory',
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                // Botones para seleccionar período
                SizedBox(
                  height: 32,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPeriodButton(
                          context,
                          ref,
                          SimpleLocalization.getText(ref, 'day'),
                          TimePeriod.daily,
                        ),
                      ),
                      Expanded(
                        child: _buildPeriodButton(
                          context,
                          ref,
                          SimpleLocalization.getText(ref, 'week'),
                          TimePeriod.weekly,
                        ),
                      ),
                      Expanded(
                        child: _buildPeriodButton(
                          context,
                          ref,
                          SimpleLocalization.getText(ref, 'month'),
                          TimePeriod.monthly,
                        ),
                      ),
                      Expanded(
                        child: _buildPeriodButton(
                          context,
                          ref,
                          SimpleLocalization.getText(ref, 'year'),
                          TimePeriod.yearly,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Botones para seleccionar tipo (Gastos/Ingresos)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 32,
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      context,
                      ref,
                      SimpleLocalization.getText(ref, 'expenses'),
                      TransactionType.expense,
                    ),
                  ),
                  Expanded(
                    child: _buildTypeButton(
                      context,
                      ref,
                      SimpleLocalization.getText(ref, 'income'),
                      TransactionType.income,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: _buildChartForPeriod(
              context,
              ref,
              transactions,
              _selectedPeriod,
              _selectedType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    TransactionType type,
  ) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    TimePeriod period,
  ) {
    final isSelected = _selectedPeriod == period;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChartForPeriod(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
    TimePeriod period,
    TransactionType type,
  ) {
    final filteredTransactions = _filterTransactionsByPeriod(
      ref,
      transactions,
      period,
    );

    final hasData = filteredTransactions.any((t) => t.type == type);

    if (!hasData) {
      return _buildEmptyChart(
        ref,
        type == TransactionType.expense
            ? SimpleLocalization.getText(ref, 'noExpenses')
            : SimpleLocalization.getText(ref, 'noIncome'),
      );
    }

    return ChartContentWidget(transactions: filteredTransactions, type: type);
  }

  List<Transaction> _filterTransactionsByPeriod(
    WidgetRef ref,
    List<Transaction> transactions,
    TimePeriod period,
  ) {
    final appConfig = ref.watch(appConfigProvider);
    final now = DateTime.now();

    switch (period) {
      case TimePeriod.daily:
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));
        return transactions.where((t) {
          return t.date.isAtSameMomentAs(todayStart) ||
              (t.date.isAfter(todayStart) && t.date.isBefore(todayEnd));
        }).toList();

      case TimePeriod.weekly:
        // Calcular inicio de semana según configuración
        int daysToSubtract;
        if (appConfig.weekStartsOnMonday) {
          // Semana inicia el lunes (weekday 1)
          daysToSubtract = now.weekday - 1;
        } else {
          // Semana inicia el domingo (weekday 7)
          daysToSubtract = now.weekday % 7;
        }

        final weekStart = DateTime(
          now.year,
          now.month,
          now.day - daysToSubtract,
          0,
          0,
          0,
        );
        final weekEnd = weekStart.add(const Duration(days: 7));
        return transactions.where((t) {
          return t.date.isAfter(
                weekStart.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(weekEnd);
        }).toList();

      case TimePeriod.monthly:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1);
        return transactions.where((t) {
          return t.date.isAfter(
                monthStart.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(monthEnd);
        }).toList();

      case TimePeriod.yearly:
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year + 1, 1, 1);
        return transactions.where((t) {
          return t.date.isAfter(
                yearStart.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(yearEnd);
        }).toList();
    }
  }

  Widget _buildEmptyChart(WidgetRef ref, [String? type]) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIconsStrokeRounded.pieChart01,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            type != null
                ? '$type ${SimpleLocalization.getText(ref, 'noDataForPeriod').toLowerCase()}'
                : SimpleLocalization.getText(ref, 'noDataForPeriod'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
