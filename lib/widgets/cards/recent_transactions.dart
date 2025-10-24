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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  SimpleLocalization.getText(ref, 'recentTransactions'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar a la pantalla de historial
                  },
                  child: Text(SimpleLocalization.getText(ref, 'viewAll')),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            if (transactions.isEmpty)
              _buildEmptyState(context, ref)
            else
              ...transactions.map(
                (transaction) =>
                    _buildTransactionItem(context, ref, transaction),
              ),
          ],
        ),
      ),
    );
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
        subtitle: Text(
          AppFormatters.formatDate(transaction.date, ref),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
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
