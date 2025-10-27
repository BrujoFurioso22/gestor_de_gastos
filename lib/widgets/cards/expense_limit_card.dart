import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_formatters.dart';
import '../../constants/app_constants.dart';
import '../../services/simple_localization.dart';

class ExpenseLimitCard extends ConsumerWidget {
  const ExpenseLimitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appConfig = ref.watch(appConfigProvider);
    final monthlyLimit = appConfig.monthlyExpenseLimit;

    // Si no hay límite configurado, no mostrar la tarjeta
    if (monthlyLimit <= 0) {
      return const SizedBox.shrink();
    }

    // Obtener gastos del mes actual
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthlyExpenses = ref
        .watch(filteredTransactionsProvider(const TransactionFilter()))
        .where(
          (transaction) =>
              transaction.type.name == 'expense' &&
              transaction.date.isAfter(startOfMonth) &&
              transaction.date.isBefore(endOfMonth),
        )
        .fold<double>(0.0, (sum, transaction) => sum + transaction.amount);

    // Calcular porcentaje
    final percentage = monthlyExpenses / monthlyLimit;
    final remaining = monthlyLimit - monthlyExpenses;

    // Determinar color según el porcentaje
    Color progressColor;
    Color backgroundColor;
    if (percentage >= 1.0) {
      progressColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
    } else if (percentage >= 0.8) {
      progressColor = Colors.orange;
      backgroundColor = Colors.orange.withOpacity(0.1);
    } else if (percentage >= 0.6) {
      progressColor = Colors.amber;
      backgroundColor = Colors.amber.withOpacity(0.1);
    } else {
      progressColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: HugeIcon(
                    icon: HugeIconsStrokeRounded.money01,
                    color: progressColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SimpleLocalization.getText(ref, 'monthlyExpenseLimit'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        percentage >= 1.0
                            ? SimpleLocalization.getText(ref, 'limitExceeded')
                            : '${SimpleLocalization.getText(ref, 'remaining')} ${_formatCurrency(remaining, ref)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Barra de progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrency(monthlyExpenses, ref),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                    Text(
                      '${SimpleLocalization.getText(ref, 'of')} ${_formatCurrency(monthlyLimit, ref)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: progressColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}% ${SimpleLocalization.getText(ref, 'used')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount, WidgetRef ref) {
    return AppFormatters.formatCurrency(amount, ref);
  }
}
