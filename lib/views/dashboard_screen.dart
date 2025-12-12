import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../utils/app_formatters.dart';
import '../utils/icon_utils.dart';
import '../widgets/cards/balance_card.dart';
import '../widgets/charts/transaction_chart.dart';
import '../widgets/cards/expense_limit_card.dart';
import '../services/feedback_service.dart';
import '../widgets/inputs/custom_floating_action_button.dart';
import '../widgets/forms/transaction_form.dart';
import '../widgets/account_selector.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionStats = ref.watch(transactionStatsProvider);
    final recentTransactions = ref
        .watch(filteredTransactionsProvider(const TransactionFilter()))
        .take(5)
        .toList();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          SimpleLocalization.getText(ref, 'appTitle'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIconsStrokeRounded.refresh, size: 20),
            onPressed: () {
              FeedbackService.buttonFeedback(ref);
              ref.read(transactionsProvider.notifier).refresh();
            },
            tooltip: SimpleLocalization.getText(ref, 'refresh'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(transactionsProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
            top: AppConstants.smallPadding,
            bottom:
                AppConstants.defaultPadding +
                MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de cuenta
              const AccountSelector(),

              const SizedBox(height: AppConstants.defaultPadding),

              // Tarjeta de balance
              BalanceCard(
                totalIncome: transactionStats.totalIncome,
                totalExpenses: transactionStats.totalExpenses,
                balance: transactionStats.balance,
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Tarjeta de límite de gastos
              const ExpenseLimitCard(),

              const SizedBox(height: AppConstants.smallPadding),

              // Gráfico de transacciones
              const TransactionChart(),

              const SizedBox(height: AppConstants.smallPadding),

              // Título de transacciones recientes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  SimpleLocalization.getText(ref, 'recentTransactions'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Transacciones recientes sin card
              _buildRecentTransactionsList(context, ref, recentTransactions),
            ],
          ),
        ),
      ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: () {
          FeedbackService.buttonFeedback(ref);
          _showAddTransactionDialog(context, ref);
        },
        iconSize: 20,
      ),
    );
  }

  Widget _buildRecentTransactionsList(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
  ) {
    final theme = Theme.of(context);

    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              HugeIcon(
                icon: HugeIconsStrokeRounded.money01,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                SimpleLocalization.getText(ref, 'noRecentTransactions'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
        if (a == 'today') return -1;
        if (b == 'today') return 1;
        if (a == 'yesterday') return -1;
        if (b == 'yesterday') return 1;
        return b.compareTo(a);
      });

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          for (int dayIndex = 0; dayIndex < sortedDays.length; dayIndex++) ...[
            if (dayIndex > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outline.withOpacity(0.2),
                indent: 0,
                endIndent: 0,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.calendar01,
                          size: 12,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDayKey(sortedDays[dayIndex], ref),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (
              int txIndex = 0;
              txIndex < groupedTransactions[sortedDays[dayIndex]]!.length;
              txIndex++
            )
              _buildTransactionItem(
                context,
                ref,
                groupedTransactions[sortedDays[dayIndex]]![txIndex],
                txIndex < groupedTransactions[sortedDays[dayIndex]]!.length - 1,
              ),
          ],
        ],
      ),
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
    bool showDivider,
  ) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == TransactionType.income;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          dense: true,
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
                            int.parse(
                              category!.color.replaceFirst('#', '0xFF'),
                            ),
                          ).withOpacity(0.1)
                        : theme.colorScheme.primaryContainer,
                    child: category?.icon != null
                        ? HugeIcon(
                            icon: IconUtils.getIconFromString(category!.icon),
                            color: Color(
                              int.parse(
                                category.color.replaceFirst('#', '0xFF'),
                              ),
                            ),
                            size: 18,
                          )
                        : HugeIcon(
                            icon: HugeIconsStrokeRounded.money01,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
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
                        size: 9,
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
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outline.withOpacity(0.2),
            indent: 60,
            endIndent: 16,
          ),
      ],
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    Transaction transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: EditTransactionSheet(transaction: transaction),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const TransactionForm(isEdit: false),
      ),
    );
  }
}
