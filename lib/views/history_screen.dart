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

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  TransactionType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(
      filteredTransactionsProvider(
        TransactionFilter(
          type: _selectedType,
          searchQuery: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalization.getText(ref, 'history')),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIconsStrokeRounded.filter, size: 20),
            onPressed: _showFilterDialog,
          ),
        ],
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

          // Lista de transacciones
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionItem(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
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
                transaction.title ?? category?.name ?? 'Sin título';
            return Text(
              displayTitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppFormatters.formatDate(transaction.date, ref),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(
                transaction.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'filterTransactions')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TransactionType?>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: SimpleLocalization.getText(ref, 'transactionType'),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    SimpleLocalization.getText(ref, 'allTransactions'),
                  ),
                ),
                DropdownMenuItem(
                  value: TransactionType.income,
                  child: Text(SimpleLocalization.getText(ref, 'income')),
                ),
                DropdownMenuItem(
                  value: TransactionType.expense,
                  child: Text(SimpleLocalization.getText(ref, 'expenses')),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
              });
              Navigator.pop(context);
            },
            child: Text(SimpleLocalization.getText(ref, 'clear')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'apply')),
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
                transaction.title ?? category?.name ?? 'Sin título';
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
