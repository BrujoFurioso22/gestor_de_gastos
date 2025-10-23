import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../models/subscription.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import 'icon_selector_widget.dart';
import 'modern_input_field.dart';
import 'modern_dropdown_field.dart';
import 'modern_date_input_field.dart';

class AddSubscriptionDialog extends ConsumerStatefulWidget {
  final Subscription? subscription;
  final Function(Subscription) onSubscriptionAdded;

  const AddSubscriptionDialog({
    super.key,
    this.subscription,
    required this.onSubscriptionAdded,
  });

  @override
  ConsumerState<AddSubscriptionDialog> createState() =>
      _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends ConsumerState<AddSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  SubscriptionFrequency _selectedFrequency = SubscriptionFrequency.monthly;
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  List<List<dynamic>> _selectedIcon = HugeIconsStrokeRounded.shoppingCart01;
  String _selectedColor = '#BBDEFB'; // Azul pastel por defecto

  final List<String> _availableColors = [
    // Colores pasteles suaves
    '#BBDEFB', // Azul pastel
    '#F8BBD9', // Rosa pastel
    '#E1BEE7', // Púrpura pastel
    '#C5CAE9', // Índigo pastel
    '#B2EBF2', // Cian pastel
    '#FFCDD2', // Rojo pastel
    '#FFE0B2', // Naranja pastel
    '#FFF9C4', // Amarillo pastel
    '#C8E6C9', // Verde pastel
    '#B2DFDB', // Verde agua pastel
    '#B0BEC5', // Gris pastel
    '#CFD8DC', // Gris azulado pastel
    '#E8F5E8', // Verde muy claro
    '#F3E5F5', // Púrpura muy claro
    '#E0F2F1', // Verde agua muy claro
    '#FFF3E0', // Naranja muy claro
  ];

  @override
  void initState() {
    super.initState();
    if (widget.subscription != null) {
      final subscription = widget.subscription!;
      _nameController.text = subscription.name;
      _descriptionController.text = subscription.description;
      _amountController.text = subscription.amount.toString();
      _notesController.text = subscription.notes ?? '';
      _selectedFrequency = subscription.frequency;
      _selectedStartDate = subscription.startDate;
      _selectedEndDate = subscription.endDate;
      _selectedColor = subscription.color;
      // Convertir el icono string a IconData si es posible
      _selectedIcon = IconUtils.getIconFromString(subscription.icon);
    }
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

    return AlertDialog(
      title: Text(
        SimpleLocalization.getText(
          ref,
          isEditing ? 'editSubscription' : 'addSubscription',
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre de la suscripción
                ModernInputField(
                  controller: _nameController,
                  label: SimpleLocalization.getText(ref, 'subscriptionName'),
                  hint: 'Ej: Netflix',
                  icon: HugeIconsStrokeRounded.edit01,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return SimpleLocalization.getText(
                        ref,
                        'subscriptionNameRequired',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Descripción
                ModernInputField(
                  controller: _descriptionController,
                  label: SimpleLocalization.getText(
                    ref,
                    'subscriptionDescription',
                  ),
                  hint: 'Ej: Streaming de películas y series',
                  icon: HugeIconsStrokeRounded.note01,
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Monto
                ModernInputField(
                  controller: _amountController,
                  label: SimpleLocalization.getText(ref, 'subscriptionAmount'),
                  hint: '0.00',
                  icon: HugeIconsStrokeRounded.money01,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return SimpleLocalization.getText(
                        ref,
                        'subscriptionAmountRequired',
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
                const SizedBox(height: AppConstants.defaultPadding),

                // Frecuencia
                ModernDropdownField<SubscriptionFrequency>(
                  value: _selectedFrequency,
                  label: SimpleLocalization.getText(
                    ref,
                    'subscriptionFrequency',
                  ),
                  hint: SimpleLocalization.getText(ref, 'selectFrequency'),
                  icon: HugeIconsStrokeRounded.refresh,
                  items: SubscriptionFrequency.values.map((frequency) {
                    return DropdownMenuItem<SubscriptionFrequency>(
                      value: frequency,
                      child: Text(
                        SimpleLocalization.getText(ref, frequency.name),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value!;
                    });
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Fecha de inicio
                ModernDateInputField(
                  value: _selectedStartDate,
                  label: SimpleLocalization.getText(ref, 'startDate'),
                  hint: SimpleLocalization.getText(ref, 'selectStartDate'),
                  icon: HugeIconsStrokeRounded.calendar01,
                  onTap: () async {
                    final date = await _selectStartDate();
                    if (date != null) {
                      setState(() {
                        _selectedStartDate = date;
                      });
                    }
                    return date;
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Fecha de fin (opcional)
                ModernDateInputField(
                  value: _selectedEndDate ?? DateTime.now(),
                  label: SimpleLocalization.getText(ref, 'endDate'),
                  hint: _selectedEndDate != null
                      ? _formatDate(_selectedEndDate!)
                      : 'Sin fecha de fin',
                  icon: HugeIconsStrokeRounded.calendar01,
                  onTap: () async {
                    final date = await _selectEndDate();
                    if (date != null) {
                      setState(() {
                        _selectedEndDate = date;
                      });
                    }
                    return date;
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Notas
                ModernInputField(
                  controller: _notesController,
                  label: SimpleLocalization.getText(ref, 'subscriptionNotes'),
                  hint: SimpleLocalization.getText(ref, 'additionalInfo'),
                  icon: HugeIconsStrokeRounded.note01,
                  maxLines: 2,
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Selector de icono
                IconSelectorWidget(
                  selectedIcon: _selectedIcon,
                  onIconChanged: (icon) {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  filterCategory: 'subscription',
                  title: SimpleLocalization.getText(ref, 'selectIcon'),
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Selector de color
                _buildColorSelector(theme),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(SimpleLocalization.getText(ref, 'cancel')),
        ),
        FilledButton(
          onPressed: _saveSubscription,
          child: Text(SimpleLocalization.getText(ref, 'save')),
        ),
      ],
    );
  }

  Widget _buildColorSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SimpleLocalization.getText(ref, 'selectColor'),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        SizedBox(
          height: 60,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              final isSelected = color == _selectedColor;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(
                                int.parse(color.replaceFirst('#', '0xFF')),
                              ).withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedStartDate = date;
      });
    }
    return date;
  }

  Future<DateTime?> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      setState(() {
        _selectedEndDate = date;
      });
    }
    return date;
  }

  void _saveSubscription() {
    if (_formKey.currentState!.validate()) {
      final subscription = Subscription(
        id: widget.subscription?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text),
        frequency: _selectedFrequency,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        icon: IconUtils.getStringFromIcon(_selectedIcon),
        color: _selectedColor,
        createdAt: widget.subscription?.createdAt,
      );

      widget.onSubscriptionAdded(subscription);
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
