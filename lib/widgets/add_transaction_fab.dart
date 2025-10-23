import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../constants/app_constants.dart';
import '../services/feedback_service.dart';
import '../services/simple_localization.dart';
import 'modern_input_field.dart';
import 'modern_dropdown_field.dart';
import 'modern_date_input_field.dart';
import 'modern_toggle_selector.dart';
import 'icon_selector_widget.dart';

class AddTransactionFAB extends ConsumerWidget {
  const AddTransactionFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () {
        FeedbackService.buttonFeedback(ref);
        _showAddTransactionDialog(context, ref);
      },
      icon: HugeIcon(icon: HugeIconsStrokeRounded.add01, size: 20),
      label: Text(SimpleLocalization.getText(ref, 'add')),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      builder: (context) => const AddTransactionSheet(),
    );
  }
}

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    SimpleLocalization.getText(ref, 'addTransaction'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: HugeIcon(
                      icon: HugeIconsStrokeRounded.cancel01,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Tipo de transacción - Modern toggle
                    _buildModernTypeSelector(theme),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Categoría - Fila completa
                    _buildModernCategorySelector(theme),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Título - Fila completa
                    ModernInputField(
                      controller: _titleController,
                      label: SimpleLocalization.getText(
                        ref,
                        'transactionTitle',
                      ),
                      hint: SimpleLocalization.getText(
                        ref,
                        'exampleSupermarket',
                      ),
                      icon: HugeIconsStrokeRounded.edit01,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return SimpleLocalization.getText(
                            ref,
                            'titleRequired',
                          );
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Monto y Fecha en una fila
                    Row(
                      children: [
                        Expanded(
                          child: ModernInputField(
                            controller: _amountController,
                            label: SimpleLocalization.getText(
                              ref,
                              'transactionAmount',
                            ),
                            hint: '0.00',
                            icon: HugeIconsStrokeRounded.money01,
                            keyboardType: TextInputType.number,
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
                                  'enterValidAmount',
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: ModernDateInputField(
                            value: _selectedDate,
                            label: SimpleLocalization.getText(
                              ref,
                              'transactionDate',
                            ),
                            hint: SimpleLocalization.getText(ref, 'selectDate'),
                            icon: HugeIconsStrokeRounded.calendar01,
                            onTap: () async {
                              final date = await _selectDate();
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                });
                              }
                              return date;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Notas - Fila completa
                    ModernInputField(
                      controller: _notesController,
                      label: SimpleLocalization.getText(ref, 'notesOptional'),
                      hint: SimpleLocalization.getText(ref, 'additionalInfo'),
                      icon: HugeIconsStrokeRounded.note01,
                      maxLines: 1,
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // Botones modernos
                    _buildModernButtons(theme),
                    const SizedBox(height: AppConstants.defaultPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTypeSelector(ThemeData theme) {
    return ModernToggleSelector<TransactionType>(
      value: _selectedType,
      options: [
        ToggleOption(
          value: TransactionType.income,
          label: SimpleLocalization.getText(ref, 'incomeType'),
          icon: HugeIconsStrokeRounded.arrowUp01,
          color: theme.colorScheme.primary,
        ),
        ToggleOption(
          value: TransactionType.expense,
          label: SimpleLocalization.getText(ref, 'expenseType'),
          icon: HugeIconsStrokeRounded.arrowDown01,
          color: theme.colorScheme.error,
        ),
      ],
      onChanged: (type) {
        setState(() {
          _selectedType = type;
          _selectedCategoryId = null;
        });
      },
    );
  }

  Widget _buildModernCategorySelector(ThemeData theme) {
    final categories = ref.watch(categoriesProvider);
    final filteredCategories = categories
        .where((category) => category.type == _selectedType)
        .toList();

    return ModernDropdownField<String>(
      value: _selectedCategoryId,
      label: SimpleLocalization.getText(ref, 'transactionCategory'),
      hint: SimpleLocalization.getText(ref, 'selectCategory'),
      icon: HugeIconsStrokeRounded.tag01,
      items: filteredCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            children: [
              HugeIcon(
                icon: IconUtils.getIconFromString(category.icon),
                size: 20,
                color: Color(
                  int.parse(category.color.replaceFirst('#', '0xFF')),
                ),
              ),
              const SizedBox(width: 12),
              Text(category.name),
            ],
          ),
        );
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

  Widget _buildModernButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: HugeIcon(icon: HugeIconsStrokeRounded.cancel01, size: 18),
            label: Text(SimpleLocalization.getText(ref, 'cancel')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveTransaction,
            icon: HugeIcon(icon: HugeIconsStrokeRounded.star, size: 18),
            label: Text(SimpleLocalization.getText(ref, 'save')),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _selectDate() async {
    return await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      try {
        final transaction = Transaction(
          type: _selectedType,
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          category: _selectedCategoryId!,
          date: _selectedDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        print('💾 Guardando transacción: ${transaction.title}');
        await ref
            .read(transactionsProvider.notifier)
            .addTransaction(transaction);
        print('✅ Transacción guardada exitosamente');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                SimpleLocalization.getText(ref, 'transactionSaved'),
              ),
            ),
          );
        }
      } catch (e) {
        print('❌ Error al guardar transacción: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${SimpleLocalization.getText(ref, 'errorSaving')} $e',
              ),
            ),
          );
        }
      }
    }
  }
}
