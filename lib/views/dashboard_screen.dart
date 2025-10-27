import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../providers/transaction_provider.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../widgets/cards/balance_card.dart';
import '../widgets/charts/transaction_chart.dart';
import '../widgets/cards/recent_transactions.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalization.getText(ref, 'appTitle')),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIconsStrokeRounded.refresh, size: 20),
            onPressed: () {
              ref.read(transactionsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(transactionsProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
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

              const SizedBox(height: AppConstants.defaultPadding),

              // Tarjeta de límite de gastos
              const ExpenseLimitCard(),

              const SizedBox(height: AppConstants.defaultPadding),

              // Gráfico de transacciones
              const TransactionChart(),

              const SizedBox(height: AppConstants.defaultPadding),

              // Transacciones recientes
              RecentTransactions(transactions: recentTransactions),
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
