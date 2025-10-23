import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../providers/transaction_provider.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_chart.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/add_transaction_fab.dart';

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
              // Tarjeta de balance
              BalanceCard(
                totalIncome: transactionStats.totalIncome,
                totalExpenses: transactionStats.totalExpenses,
                balance: transactionStats.balance,
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Gráfico de transacciones
              TransactionChart(
                income: transactionStats.totalIncome,
                expenses: transactionStats.totalExpenses,
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Transacciones recientes
              RecentTransactions(transactions: recentTransactions),
            ],
          ),
        ),
      ),
      floatingActionButton: const AddTransactionFAB(),
    );
  }
}
