import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
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
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  SubscriptionFrequency _selectedFrequency = SubscriptionFrequency.monthly;
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  bool _hasEndDate = false;

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
    _descriptionController.text = subscription.description;
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
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.borderRadius),
                  topRight: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: widget.isEdit
                        ? HugeIconsStrokeRounded.edit01
                        : HugeIconsStrokeRounded.add01,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEdit
                        ? SimpleLocalization.getText(ref, 'editSubscription')
                        : SimpleLocalization.getText(ref, 'addSubscription'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Form content
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                        return SimpleLocalization.getText(ref, 'nameRequired');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText:
                          '${SimpleLocalization.getText(ref, 'description')} *',
                      hintText: SimpleLocalization.getText(
                        ref,
                        'subscriptionDescriptionHint',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Amount field
                  TextFormField(
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
                        return SimpleLocalization.getText(ref, 'invalidAmount');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Frequency selector
                  _buildFrequencySelector(theme),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Start date selector
                  _buildStartDateSelector(theme),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // End date selector
                  _buildEndDateSelector(theme),

                  const SizedBox(height: AppConstants.defaultPadding),

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

                  const SizedBox(height: AppConstants.largePadding),

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
    return Column(
      children: [
        Row(
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
            Text(SimpleLocalization.getText(ref, 'hasEndDate')),
          ],
        ),
        if (_hasEndDate) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectEndDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText:
                    '${SimpleLocalization.getText(ref, 'endDate')} (${SimpleLocalization.getText(ref, 'optional')})',
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
          ),
        ],
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
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      if (widget.isEdit && widget.subscription != null) {
        // Update existing subscription
        final updatedSubscription = widget.subscription!.copyWith(
          name: name,
          description: description,
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
          description: description ?? '',
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
