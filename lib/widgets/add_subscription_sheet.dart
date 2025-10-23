import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../constants/app_constants.dart';

class AddSubscriptionSheet extends ConsumerStatefulWidget {
  final Subscription? subscription;

  const AddSubscriptionSheet({super.key, this.subscription});

  @override
  ConsumerState<AddSubscriptionSheet> createState() =>
      _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends ConsumerState<AddSubscriptionSheet> {
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
    if (widget.subscription != null) {
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
    final isEditing = widget.subscription != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar Suscripción' : 'Agregar Suscripción',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ej: Netflix',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ej: Streaming de películas y series',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Monto y Frecuencia
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Monto',
                            hintText: '0.00',
                            prefixText: '€',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El monto es obligatorio';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Ingresa un monto válido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<SubscriptionFrequency>(
                          value: _selectedFrequency,
                          decoration: const InputDecoration(
                            labelText: 'Frecuencia',
                          ),
                          items: SubscriptionFrequency.values.map((frequency) {
                            return DropdownMenuItem(
                              value: frequency,
                              child: Text(frequency.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFrequency = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Fecha de inicio
                  _buildDateSelector(
                    theme,
                    'Fecha de inicio',
                    _selectedStartDate,
                    (date) => setState(() => _selectedStartDate = date),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Fecha de fin (opcional)
                  Row(
                    children: [
                      Checkbox(
                        value: _hasEndDate,
                        onChanged: (value) {
                          setState(() {
                            _hasEndDate = value ?? false;
                            if (!_hasEndDate) {
                              _selectedEndDate = null;
                            }
                          });
                        },
                      ),
                      const Text('Tiene fecha de fin'),
                    ],
                  ),
                  if (_hasEndDate) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    _buildDateSelector(
                      theme,
                      'Fecha de fin',
                      _selectedEndDate ??
                          DateTime.now().add(const Duration(days: 365)),
                      (date) => setState(() => _selectedEndDate = date),
                    ),
                  ],
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Notas
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      hintText: 'Información adicional...',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isEditing
                              ? _updateSubscription
                              : _saveSubscription,
                          child: Text(isEditing ? 'Actualizar' : 'Guardar'),
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

  Widget _buildDateSelector(
    ThemeData theme,
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        );

        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSubscription() async {
    if (_formKey.currentState!.validate()) {
      try {
        final subscription = Subscription(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          amount: double.parse(_amountController.text),
          frequency: _selectedFrequency,
          startDate: _selectedStartDate,
          endDate: _hasEndDate ? _selectedEndDate : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          icon: '📱',
          color: '#6750A4',
        );

        print('💾 Guardando suscripción: ${subscription.name}');
        await ref
            .read(subscriptionsProvider.notifier)
            .addSubscription(subscription);
        print('✅ Suscripción guardada exitosamente');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Suscripción guardada correctamente')),
          );
        }
      } catch (e) {
        print('❌ Error al guardar suscripción: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
        }
      }
    }
  }

  Future<void> _updateSubscription() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedSubscription = widget.subscription!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          amount: double.parse(_amountController.text),
          frequency: _selectedFrequency,
          startDate: _selectedStartDate,
          endDate: _hasEndDate ? _selectedEndDate : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          icon: '📱',
          color: '#6750A4',
        );

        print('🔄 Actualizando suscripción: ${updatedSubscription.name}');
        await ref
            .read(subscriptionsProvider.notifier)
            .updateSubscription(updatedSubscription);
        print('✅ Suscripción actualizada exitosamente');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suscripción actualizada correctamente'),
            ),
          );
        }
      } catch (e) {
        print('❌ Error al actualizar suscripción: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
        }
      }
    }
  }
}
