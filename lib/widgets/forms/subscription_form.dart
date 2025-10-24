import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/subscription.dart';
import '../../models/transaction.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../constants/app_constants.dart';
import '../../services/simple_localization.dart';
import '../../utils/app_formatters.dart';

class SubscriptionForm extends ConsumerStatefulWidget {
  final Subscription? subscription;
  final bool isEdit;

  const SubscriptionForm({super.key, this.subscription, this.isEdit = false});

  @override
  ConsumerState<SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends ConsumerState<SubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  SubscriptionFrequency _selectedFrequency = SubscriptionFrequency.monthly;
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  bool _hasEndDate = false;
  bool _addPaymentOnCreate = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.subscription != null) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    final subscription = widget.subscription!;
    _nameController.text = subscription.name;
    _amountController.text = subscription.amount.toString();
    _notesController.text = subscription.notes ?? '';
    _selectedFrequency = subscription.frequency;
    _selectedStartDate = subscription.startDate;
    _selectedEndDate = subscription.endDate;
    _hasEndDate = subscription.endDate != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  child: Column(
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: SimpleLocalization.getText(
                            ref,
                            'subscriptionName',
                          ),
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
                              'nameRequired',
                            );
                          }
                          return null;
                        },
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
                          hintText: SimpleLocalization.getText(
                            ref,
                            'subscriptionNotesHint',
                          ),
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
                                'addPaymentOnCreate',
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
                              onPressed: _saveSubscription,
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
    return DropdownButtonFormField<SubscriptionFrequency>(
      value: _selectedFrequency,
      decoration: InputDecoration(
        labelText: '${SimpleLocalization.getText(ref, 'frequency')} *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      items: SubscriptionFrequency.values.map((frequency) {
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

  String _getFrequencyLabel(SubscriptionFrequency frequency) {
    switch (frequency) {
      case SubscriptionFrequency.daily:
        return SimpleLocalization.getText(ref, 'daily');
      case SubscriptionFrequency.weekly:
        return SimpleLocalization.getText(ref, 'weekly');
      case SubscriptionFrequency.monthly:
        return SimpleLocalization.getText(ref, 'monthly');
      case SubscriptionFrequency.yearly:
        return SimpleLocalization.getText(ref, 'yearly');
      case SubscriptionFrequency.quarterly:
        return SimpleLocalization.getText(ref, 'quarterly');
    }
  }

  void _saveSubscription() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      if (widget.isEdit && widget.subscription != null) {
        // Update existing subscription
        final updatedSubscription = widget.subscription!.copyWith(
          name: name,
          description: '', // Mantener descripción vacía
          amount: amount,
          frequency: _selectedFrequency,
          startDate: _selectedStartDate,
          endDate: _hasEndDate ? _selectedEndDate : null,
          notes: notes,
        );

        ref
            .read(subscriptionsProvider.notifier)
            .updateSubscription(updatedSubscription);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              SimpleLocalization.getText(ref, 'subscriptionUpdated'),
            ),
          ),
        );
      } else {
        // Create new subscription
        final newSubscription = Subscription(
          name: name,
          description: '', // Descripción vacía
          amount: amount,
          frequency: _selectedFrequency,
          startDate: _selectedStartDate,
          endDate: _hasEndDate ? _selectedEndDate : null,
          notes: notes,
          icon: 'subscription01', // Default icon
          color: '#FFCDD2', // Default color
        );

        ref
            .read(subscriptionsProvider.notifier)
            .addSubscription(newSubscription);

        // Si está marcado agregar pago al crear, crear una transacción
        if (_addPaymentOnCreate) {
          final paymentTransaction = Transaction(
            type: TransactionType.expense,
            title: 'Pago de suscripción: ${newSubscription.name}',
            amount: amount,
            category: 'expense_subscriptions', // Usar la categoría correcta
            date: _selectedStartDate,
            notes: 'Pago inicial de suscripción',
          );

          ref
              .read(transactionsProvider.notifier)
              .addTransaction(paymentTransaction);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SimpleLocalization.getText(ref, 'subscriptionAdded')),
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  String _getCurrencySymbol(WidgetRef ref) {
    // This would need to be implemented based on your app config
    return '\$';
  }
}

// Sheet widget for adding subscriptions
class AddSubscriptionSheet extends ConsumerWidget {
  final Subscription? subscription;

  const AddSubscriptionSheet({super.key, this.subscription});

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
      child: SubscriptionForm(
        subscription: subscription,
        isEdit: subscription != null,
      ),
    );
  }
}
