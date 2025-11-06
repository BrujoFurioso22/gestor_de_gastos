import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/recurring_payment.dart';
import '../../models/transaction.dart';
import '../../providers/recurring_payment_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../constants/app_constants.dart';
import '../../services/simple_localization.dart';
import '../../utils/app_formatters.dart';
import '../../utils/icon_utils.dart';
import '../inputs/transaction_type_selector.dart';
import '../selectors/category_selector_page.dart';

class RecurringPaymentForm extends ConsumerStatefulWidget {
  final RecurringPayment? recurringPayment;
  final bool isEdit;

  const RecurringPaymentForm({
    super.key,
    this.recurringPayment,
    this.isEdit = false,
  });

  @override
  ConsumerState<RecurringPaymentForm> createState() =>
      _RecurringPaymentFormState();
}

class _RecurringPaymentFormState extends ConsumerState<RecurringPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  RecurringFrequency _selectedFrequency = RecurringFrequency.monthly;
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  bool _hasEndDate = false;
  bool _addPaymentOnCreate = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.recurringPayment != null) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    final payment = widget.recurringPayment!;
    _nameController.text = payment.name;
    _descriptionController.text = payment.description ?? '';
    _amountController.text = payment.amount.toString();
    _notesController.text = payment.notes ?? '';
    _selectedType = payment.type;
    _selectedCategoryId = payment.category;
    _selectedFrequency = payment.frequency;
    _selectedStartDate = payment.startDate;
    _selectedEndDate = payment.endDate;
    _hasEndDate = payment.endDate != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = _selectedCategoryId != null
        ? categories.firstWhere(
            (cat) => cat.id == _selectedCategoryId,
            orElse: () => categories.first,
          )
        : null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        widget.isEdit
                            ? SimpleLocalization.getText(
                                ref,
                                'editRecurringPayment',
                              )
                            : SimpleLocalization.getText(
                                ref,
                                'addRecurringPayment',
                              ),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),

                      // Type selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${SimpleLocalization.getText(ref, 'recurringPaymentType')} *',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TransactionTypeSelector(
                            value: _selectedType,
                            onChanged: (type) {
                              setState(() {
                                _selectedType = type;
                                _selectedCategoryId = null; // Reset category
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.smallPadding),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText:
                              '${SimpleLocalization.getText(ref, 'recurringPaymentName')} *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return SimpleLocalization.getText(
                              ref,
                              'recurringPaymentNameRequired',
                            );
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppConstants.smallPadding),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: SimpleLocalization.getText(
                            ref,
                            'recurringPaymentDescription',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallPadding),

                      // Category selector
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategorySelectorPage(
                                categoryType: _selectedType,
                                selectedCategoryId: _selectedCategoryId,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _selectedCategoryId = result;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText:
                                '${SimpleLocalization.getText(ref, 'recurringPaymentCategory')} *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                            suffixIcon: const Icon(Icons.arrow_forward_ios,
                                size: 16),
                          ),
                          child: Row(
                            children: [
                              if (selectedCategory != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(
                                      selectedCategory.color
                                          .replaceFirst('#', '0xFF'),
                                    )),
                                    shape: BoxShape.circle,
                                  ),
                                  child: HugeIcon(
                                    icon: IconUtils.getIconFromString(
                                      selectedCategory.icon,
                                    ),
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedCategory.name,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ] else
                                Text(
                                  SimpleLocalization.getText(
                                    ref,
                                    'selectRecurringPaymentCategory',
                                  ),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallPadding),

                      // Amount and Start Date in same row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText:
                                    '${SimpleLocalization.getText(ref, 'recurringPaymentAmount')} *',
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
                                    'recurringPaymentAmountRequired',
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
                          Expanded(
                            flex: 3,
                            child: _buildStartDateSelector(theme),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.smallPadding),

                      // Frequency selector
                      _buildFrequencySelector(theme),

                      const SizedBox(height: AppConstants.smallPadding),

                      // Notes field
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText:
                              '${SimpleLocalization.getText(ref, 'notes')} (${SimpleLocalization.getText(ref, 'optional')})',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallPadding),

                      // End date selector
                      _buildEndDateSelector(theme),

                      const SizedBox(height: AppConstants.smallPadding),

                      // Add payment on create checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _addPaymentOnCreate,
                            onChanged: (value) {
                              setState(() {
                                _addPaymentOnCreate = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              SimpleLocalization.getText(
                                ref,
                                'addPaymentOnCreateRecurringPayment',
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
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
                              onPressed: _saveRecurringPayment,
                              child: Text(
                                widget.isEdit
                                    ? SimpleLocalization.getText(ref, 'update')
                                    : SimpleLocalization.getText(ref, 'save'),
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
      ),
    );
  }

  Widget _buildFrequencySelector(ThemeData theme) {
    return DropdownButtonFormField<RecurringFrequency>(
      value: _selectedFrequency,
      decoration: InputDecoration(
        labelText:
            '${SimpleLocalization.getText(ref, 'recurringPaymentFrequency')} *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      items: RecurringFrequency.values.map((frequency) {
        return DropdownMenuItem(
          value: frequency,
          child: Text(_getFrequencyLabel(frequency)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedFrequency = value!;
        });
      },
    );
  }

  Widget _buildStartDateSelector(ThemeData theme) {
    return InkWell(
      onTap: _selectStartDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '${SimpleLocalization.getText(ref, 'startDate')} *',
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
              AppFormatters.formatDate(_selectedStartDate, ref),
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndDateSelector(ThemeData theme) {
    return Row(
      children: [
        Checkbox(
          value: _hasEndDate,
          onChanged: (value) {
            setState(() {
              _hasEndDate = value!;
              if (!_hasEndDate) {
                _selectedEndDate = null;
              }
            });
          },
        ),
        Expanded(
          child: _hasEndDate
              ? InkWell(
                  onTap: _selectEndDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: SimpleLocalization.getText(ref, 'endDate'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
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
                          _selectedEndDate != null
                              ? AppFormatters.formatDate(_selectedEndDate!, ref)
                              : SimpleLocalization.getText(ref, 'selectDate'),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                )
              : Text(
                  SimpleLocalization.getText(ref, 'hasEndDate'),
                  style: theme.textTheme.bodyMedium,
                ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate,
      firstDate: _selectedStartDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  String _getFrequencyLabel(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return SimpleLocalization.getText(ref, 'daily');
      case RecurringFrequency.weekly:
        return SimpleLocalization.getText(ref, 'weekly');
      case RecurringFrequency.monthly:
        return SimpleLocalization.getText(ref, 'monthly');
      case RecurringFrequency.quarterly:
        return SimpleLocalization.getText(ref, 'quarterly');
      case RecurringFrequency.yearly:
        return SimpleLocalization.getText(ref, 'yearly');
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
        return '\$';
      case 'AUD':
        return '\$';
      default:
        return '€';
    }
  }

  Future<void> _saveRecurringPayment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              SimpleLocalization.getText(
                ref,
                'recurringPaymentCategoryRequired',
              ),
            ),
          ),
        );
        return;
      }

      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      // Obtener icono y color de la categoría
      final categories = ref.read(categoriesProvider);
      final selectedCategory = categories.firstWhere(
        (cat) => cat.id == _selectedCategoryId,
      );

      if (widget.isEdit && widget.recurringPayment != null) {
        // Update existing payment
        final updatedPayment = widget.recurringPayment!.copyWith(
          name: name,
          description: description,
          amount: amount,
          type: _selectedType,
          category: _selectedCategoryId!,
          frequency: _selectedFrequency,
          startDate: _selectedStartDate,
          endDate: _hasEndDate ? _selectedEndDate : null,
          notes: notes,
          icon: selectedCategory.icon,
          color: selectedCategory.color,
        );

        ref
            .read(recurringPaymentsProvider.notifier)
            .updateRecurringPayment(updatedPayment);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              SimpleLocalization.getText(ref, 'recurringPaymentUpdated'),
            ),
          ),
        );
      } else {
        // Create new payment
        final newPayment = RecurringPayment(
          name: name,
          description: description,
          amount: amount,
          type: _selectedType,
          category: _selectedCategoryId!,
          frequency: _selectedFrequency,
          startDate: _selectedStartDate,
          endDate: _hasEndDate ? _selectedEndDate : null,
          notes: notes,
          icon: selectedCategory.icon,
          color: selectedCategory.color,
        );

        ref
            .read(recurringPaymentsProvider.notifier)
            .addRecurringPayment(newPayment);

        // Si se marcó "agregar pago al crear", crear la transacción
        if (_addPaymentOnCreate) {
          await ref
              .read(recurringPaymentsProvider.notifier)
              .createTransactionFromPayment(newPayment);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              SimpleLocalization.getText(ref, 'recurringPaymentCreated'),
            ),
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}

