import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_formatters.dart';
import '../utils/icon_utils.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../widgets/forms/transaction_form.dart';
import '../widgets/inputs/search_input_field.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalization.getText(ref, 'history')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: SimpleLocalization.getText(ref, 'all')),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(icon: HugeIconsStrokeRounded.money01, size: 16),
                  const SizedBox(width: 4),
                  Text(SimpleLocalization.getText(ref, 'income')),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(icon: HugeIconsStrokeRounded.dollar01, size: 16),
                  const SizedBox(width: 4),
                  Text(SimpleLocalization.getText(ref, 'expenses')),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SearchInputField(
              controller: _searchController,
              hintText: SimpleLocalization.getText(ref, 'searchTransactions'),
              onChanged: () {
                setState(() {});
              },
              onClear: () {
                setState(() {});
              },
            ),
          ),

          // Lista de transacciones agrupadas por día con tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab: Todas las transacciones
                _buildTransactionsList(null),
                // Tab: Solo ingresos
                _buildTransactionsList(TransactionType.income),
                // Tab: Solo gastos
                _buildTransactionsList(TransactionType.expense),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(TransactionType? filterType) {
    final transactions = ref.watch(
      filteredTransactionsProvider(
        TransactionFilter(
          type: filterType,
          searchQuery: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        ),
      ),
    );

    return transactions.isEmpty
        ? _buildEmptyState()
        : _buildGroupedTransactions(transactions);
  }

  Widget _buildGroupedTransactions(List<Transaction> transactions) {
    final theme = Theme.of(context);

    // Agrupar transacciones por día
    final groupedTransactions = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      final dayKey = _getDayKey(transaction.date);
      if (!groupedTransactions.containsKey(dayKey)) {
        groupedTransactions[dayKey] = [];
      }
      groupedTransactions[dayKey]!.add(transaction);
    }

    final sortedDays = groupedTransactions.keys.toList()
      ..sort((a, b) {
        // Orden personalizado: today > yesterday > fechas (más recientes primero)
        if (a == 'today') return -1;
        if (b == 'today') return 1;
        if (a == 'yesterday') return -1;
        if (b == 'yesterday') return 1;
        return b.compareTo(a); // Para fechas, más recientes primero
      });

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      itemCount: sortedDays.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final dayKey = sortedDays[index];
        final dayTransactions = groupedTransactions[dayKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del día
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.calendar01,
                          size: 16,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDayKey(dayKey),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${dayTransactions.length} ${dayTransactions.length == 1 ? SimpleLocalization.getText(ref, 'transaction') : SimpleLocalization.getText(ref, 'transactions')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Transacciones del día
            ...dayTransactions.map(
              (transaction) => _buildTransactionItem(transaction),
            ),
          ],
        );
      },
    );
  }

  String _getDayKey(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'yesterday';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  String _formatDayKey(String key) {
    if (key == 'today') {
      return SimpleLocalization.getText(ref, 'today');
    } else if (key == 'yesterday') {
      return SimpleLocalization.getText(ref, 'yesterday');
    } else {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final date = DateTime(year, month, day);

      return AppFormatters.formatDate(date, ref);
    }
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == TransactionType.income;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
      child: ListTile(
        leading: Consumer(
          builder: (context, ref, child) {
            final category = ref.watch(
              categoryByIdProvider(transaction.category),
            );
            return Stack(
              children: [
                CircleAvatar(
                  backgroundColor: category?.color != null
                      ? Color(
                          int.parse(category!.color.replaceFirst('#', '0xFF')),
                        ).withOpacity(0.1)
                      : theme.colorScheme.primaryContainer,
                  child: category?.icon != null
                      ? HugeIcon(
                          icon: IconUtils.getIconFromString(category!.icon),
                          color: Color(
                            int.parse(category.color.replaceFirst('#', '0xFF')),
                          ),
                        )
                      : HugeIcon(
                          icon: isIncome
                              ? HugeIconsStrokeRounded.money01
                              : HugeIconsStrokeRounded.money01,
                          color: theme.colorScheme.primary,
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isIncome
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isIncome ? Icons.add : Icons.remove,
                      size: 10,
                      color: theme.colorScheme.surface,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        title: Consumer(
          builder: (context, ref, child) {
            final category = ref.watch(
              categoryByIdProvider(transaction.category),
            );
            final displayTitle =
                transaction.title ??
                category?.name ??
                SimpleLocalization.getText(ref, 'noTitle');
            return Text(
              displayTitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        subtitle: transaction.notes != null && transaction.notes!.isNotEmpty
            ? Text(
                transaction.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Consumer(
          builder: (context, ref, child) {
            final category = ref.watch(
              categoryByIdProvider(transaction.category),
            );
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.formatAmountWithSign(
                    isIncome ? transaction.amount : -transaction.amount,
                    ref,
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isIncome
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  category?.name ?? transaction.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
        onTap: () {
          _showEditTransactionDialog(transaction);
        },
        onLongPress: () {
          _showDeleteDialog(transaction);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIconsStrokeRounded.money01,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            SimpleLocalization.getText(ref, 'noTransactions'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            SimpleLocalization.getText(ref, 'addFirstTransaction'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTransactionDialog(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      builder: (context) => EditTransactionSheet(transaction: transaction),
    );
  }

  void _showDeleteDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'deleteTransaction')),
        content: Consumer(
          builder: (context, ref, child) {
            final category = ref.watch(
              categoryByIdProvider(transaction.category),
            );
            final displayTitle =
                transaction.title ??
                category?.name ??
                SimpleLocalization.getText(ref, 'noTitle');
            return Text(
              SimpleLocalization.getText(
                ref,
                'deleteTransactionConfirm',
              ).replaceAll('{title}', displayTitle),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(transactionsProvider.notifier)
                  .deleteTransaction(transaction.id);
              Navigator.pop(context);
            },
            child: Text(SimpleLocalization.getText(ref, 'delete')),
          ),
        ],
      ),
    );
  }
}
