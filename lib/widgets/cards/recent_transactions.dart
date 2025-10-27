import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../utils/app_formatters.dart';
import '../../utils/icon_utils.dart';
import '../../services/simple_localization.dart';
import '../../constants/app_constants.dart';
import '../forms/transaction_form.dart';

class RecentTransactions extends ConsumerWidget {
  final List<Transaction> transactions;

  const RecentTransactions({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SimpleLocalization.getText(ref, 'recentTransactions'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            if (transactions.isEmpty)
              _buildEmptyState(context, ref)
            else
              _buildGroupedTransactions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedTransactions(BuildContext context, WidgetRef ref) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final dayKey in sortedDays) ...[
          // Header del día
          Padding(
            padding: EdgeInsets.only(
              top: dayKey == sortedDays.first ? 0 : 8,
              bottom: 4,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.calendar01,
                    size: 14,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDayKey(dayKey, ref),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (groupedTransactions[dayKey]!.length > 1) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· ${groupedTransactions[dayKey]!.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Transacciones del día
          for (final transaction in groupedTransactions[dayKey]!)
            _buildTransactionItem(context, ref, transaction),
        ],
      ],
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

  String _formatDayKey(String key, WidgetRef ref) {
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

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == TransactionType.income;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
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
                          size: 20,
                        )
                      : HugeIcon(
                          icon: HugeIconsStrokeRounded.money01,
                          color: theme.colorScheme.primary,
                          size: 20,
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
                transaction.title ?? category?.name ?? 'Sin título';
            return Text(
              displayTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
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
        trailing: Text(
          AppFormatters.formatAmountWithSign(
            isIncome ? transaction.amount : -transaction.amount,
            ref,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isIncome
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          _showEditTransactionDialog(context, transaction);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.defaultPadding,
      ),
      child: Center(
        child: Column(
          children: [
            HugeIcon(
              icon: HugeIconsStrokeRounded.money01,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              SimpleLocalization.getText(ref, 'noRecentTransactions'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              SimpleLocalization.getText(ref, 'addFirstTransaction'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    Transaction transaction,
  ) {
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
}
