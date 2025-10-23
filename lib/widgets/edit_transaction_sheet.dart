import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../constants/app_constants.dart';

class EditTransactionSheet extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionSheet({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
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
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.transaction.title;
    _amountController.text = widget.transaction.amount.toString();
    _notesController.text = widget.transaction.notes ?? '';
    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;
    _selectedCategoryId = widget.transaction.category;
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
                  'Editar Transacción',
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
                  // Tipo de transacción
                  _buildTypeSelector(theme),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Categoría
                  _buildCategorySelector(theme),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Ej: Compra de supermercado',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El título es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Monto
                  TextFormField(
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
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Fecha
                  _buildDateSelector(theme),
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
                          onPressed: _updateTransaction,
                          child: const Text('Actualizar'),
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

  Widget _buildTypeSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<TransactionType>(
            title: const Text('Ingreso'),
            value: TransactionType.income,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                _selectedCategoryId = null; // Reset category when type changes
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<TransactionType>(
            title: const Text('Gasto'),
            value: TransactionType.expense,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                _selectedCategoryId = null; // Reset category when type changes
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    final categories = ref.watch(categoriesProvider);
    final filteredCategories = categories
        .where((category) => category.type == _selectedType)
        .toList();

    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Categoría',
        hintText: 'Selecciona una categoría',
      ),
      items: filteredCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            children: [
              Text(category.icon),
              const SizedBox(width: 8),
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
          return 'La categoría es obligatoria';
        }
        return null;
      },
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Fecha'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedTransaction = widget.transaction.copyWith(
          type: _selectedType,
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          category: _selectedCategoryId!,
          date: _selectedDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        print('🔄 Actualizando transacción: ${updatedTransaction.title}');
        await ref
            .read(transactionsProvider.notifier)
            .updateTransaction(updatedTransaction);
        print('✅ Transacción actualizada exitosamente');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transacción actualizada correctamente'),
            ),
          );
        }
      } catch (e) {
        print('❌ Error al actualizar transacción: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
        }
      }
    }
  }
}
