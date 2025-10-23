import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../utils/app_formatters.dart';
import '../../services/simple_localization.dart';
import '../../constants/app_constants.dart';

class TransactionChart extends ConsumerWidget {
  final double income;
  final double expenses;

  const TransactionChart({
    super.key,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final total = income + expenses;

    if (total == 0) {
      return _buildEmptyChart(context, ref);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SimpleLocalization.getText(ref, 'distributionOfExpenses'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Gráfico circular
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(context),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  // Leyenda
                  Expanded(child: _buildLegend(context, ref)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(BuildContext context) {
    final theme = Theme.of(context);
    final total = income + expenses;

    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: theme.colorScheme.primary,
        value: income,
        title: '${((income / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: theme.colorScheme.error,
        value: expenses,
        title: '${((expenses / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onError,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  Widget _buildLegend(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(
          context,
          ref,
          SimpleLocalization.getText(ref, 'income'),
          income,
          theme.colorScheme.primary,
          HugeIconsStrokeRounded.arrowUp01,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        _buildLegendItem(
          context,
          ref,
          SimpleLocalization.getText(ref, 'expenses'),
          expenses,
          theme.colorScheme.error,
          HugeIconsStrokeRounded.arrowDown01,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    WidgetRef ref,
    String label,
    double amount,
    Color color,
    List<List<dynamic>> icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(amount, ref),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Text(
              SimpleLocalization.getText(ref, 'distributionOfExpenses'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.pieChart01,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'No hay datos para mostrar',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
