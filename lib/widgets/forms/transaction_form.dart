import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../constants/app_constants.dart';
import '../../services/feedback_service.dart';
import '../../services/simple_localization.dart';
import '../../utils/app_formatters.dart';
import '../inputs/modern_toggle_selector.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final Transaction? transaction;
  final bool isEdit;

  const TransactionForm({super.key, this.transaction, this.isEdit = false});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.transaction != null) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    final transaction = widget.transaction!;
    _titleController.text = transaction.title ?? '';
    _amountController.text = transaction.amount.toString();
    _notesController.text = transaction.notes ?? '';
    _selectedType = transaction.type;
    _selectedDate = transaction.date;

    // Verificar que la categoría existe antes de establecerla
    final categories = ref.read(categoriesProvider);
    final categoryExists = categories.any(
      (cat) => cat.id == transaction.category,
    );
    _selectedCategoryId = categoryExists ? transaction.category : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.smallPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              // Form content
              Padding(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                child: Column(
                  children: [
                    // Transaction type selector
                    _buildTypeSelector(theme),

                    const SizedBox(height: AppConstants.smallPadding),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText:
                            '${SimpleLocalization.getText(ref, 'title')} (${SimpleLocalization.getText(ref, 'optional')})',
                        hintText: SimpleLocalization.getText(ref, 'titleHint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.smallPadding),

                    // Amount and Date in same row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  '${SimpleLocalization.getText(ref, 'amount')} *',
                              prefixText: _getCurrencySymbol(ref),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return SimpleLocalization.getText(
                                  ref,
                                  'amountRequired',
                                );
                              }
                              if (double.tryParse(value) == null) {
                                return SimpleLocalization.getText(
                                  ref,
                                  'invalidAmount',
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(flex: 3, child: _buildDateSelector(theme)),
                      ],
                    ),

                    const SizedBox(height: AppConstants.smallPadding),

                    // Category selector
                    _buildCategorySelector(theme, categories),

                    const SizedBox(height: AppConstants.smallPadding),

                    // Notes field
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText:
                            '${SimpleLocalization.getText(ref, 'notes')} (${SimpleLocalization.getText(ref, 'optional')})',
                        hintText: SimpleLocalization.getText(
                          ref,
                          'transactionNotesHint',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              SimpleLocalization.getText(ref, 'cancel'),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saveTransaction,
                            child: Text(
                              widget.isEdit
                                  ? SimpleLocalization.getText(ref, 'update')
                                  : SimpleLocalization.getText(ref, 'add'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return ModernToggleSelector<TransactionType>(
      value: _selectedType,
      options: [
        ToggleOption(
          value: TransactionType.income,
          label: SimpleLocalization.getText(ref, 'income'),
          icon: HugeIconsStrokeRounded.arrowUp01,
          color: theme.colorScheme.primary,
        ),
        ToggleOption(
          value: TransactionType.expense,
          label: SimpleLocalization.getText(ref, 'expense'),
          icon: HugeIconsStrokeRounded.arrowDown01,
          color: theme.colorScheme.error,
        ),
      ],
      onChanged: (type) {
        setState(() {
          _selectedType = type;
        });
      },
    );
  }

  Widget _buildCategorySelector(ThemeData theme, List<Category> categories) {
    final filteredCategories = categories
        .where((cat) => cat.type == _selectedType)
        .toList();

    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: '${SimpleLocalization.getText(ref, 'category')} *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      items: filteredCategories.map((category) {
        return DropdownMenuItem(value: category.id, child: Text(category.name));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return SimpleLocalization.getText(ref, 'categoryRequired');
        }
        return null;
      },
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '${SimpleLocalization.getText(ref, 'date')} *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIconsStrokeRounded.calendar01,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              AppFormatters.formatDate(_selectedDate, ref),
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SimpleLocalization.getText(ref, 'categoryRequired')),
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final title = _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      if (widget.isEdit && widget.transaction != null) {
        // Update existing transaction
        final updatedTransaction = widget.transaction!.copyWith(
          type: _selectedType,
          title: title,
          amount: amount,
          category: _selectedCategoryId!,
          date: _selectedDate,
          notes: notes,
        );

        ref
            .read(transactionsProvider.notifier)
            .updateTransaction(updatedTransaction);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              SimpleLocalization.getText(ref, 'transactionUpdated'),
            ),
          ),
        );
      } else {
        // Create new transaction
        final newTransaction = Transaction(
          type: _selectedType,
          title: title,
          amount: amount,
          category: _selectedCategoryId!,
          date: _selectedDate,
          notes: notes,
        );

        ref.read(transactionsProvider.notifier).addTransaction(newTransaction);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SimpleLocalization.getText(ref, 'transactionAdded')),
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  String _getCurrencySymbol(WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    switch (appConfig.currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'MXN':
        return '\$';
      case 'GBP':
        return '£';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return '\$';
    }
  }
}

// FAB widget for adding transactions
class AddTransactionFAB extends ConsumerWidget {
  const AddTransactionFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        FeedbackService.buttonFeedback(ref);
        _showAddTransactionDialog(context, ref);
      },
      child: HugeIcon(icon: HugeIconsStrokeRounded.add01, size: 20),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.borderRadius),
            topRight: Radius.circular(AppConstants.borderRadius),
          ),
        ),
        child: TransactionForm(isEdit: false),
      ),
    );
  }
}

// Sheet widget for editing transactions
class EditTransactionSheet extends ConsumerWidget {
  final Transaction transaction;

  const EditTransactionSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadius),
          topRight: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      child: TransactionForm(transaction: transaction, isEdit: true),
    );
  }
}
