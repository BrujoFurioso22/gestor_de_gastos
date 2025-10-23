import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import 'icon_selector_widget.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  final Category? category;
  final Function(Category) onCategoryAdded;

  const AddCategoryDialog({
    super.key,
    this.category,
    required this.onCategoryAdded,
  });

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  List<List<dynamic>> _selectedIcon = HugeIconsStrokeRounded.shoppingCart01;
  String _selectedColor = '#FFCDD2'; // Rojo pastel por defecto

  final List<String> _availableColors = [
    // Colores pasteles suaves
    '#FFCDD2', // Rojo pastel
    '#F8BBD9', // Rosa pastel
    '#E1BEE7', // Púrpura pastel
    '#C5CAE9', // Índigo pastel
    '#BBDEFB', // Azul pastel
    '#B2EBF2', // Cian pastel
    '#B2DFDB', // Verde agua pastel
    '#C8E6C9', // Verde pastel
    '#DCEDC8', // Verde lima pastel
    '#F0F4C3', // Amarillo pastel
    '#FFF9C4', // Amarillo claro pastel
    '#FFE0B2', // Naranja pastel
    '#FFCCBC', // Naranja rojizo pastel
    '#D7CCC8', // Marrón pastel
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
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedColor = widget.category!.color;
      // Convertir el icono string a IconData si es posible
      _selectedIcon = IconUtils.getIconFromString(widget.category!.icon);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(
        SimpleLocalization.getText(
          ref,
          isEditing ? 'editCategory' : 'addCategory',
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre de la categoría
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: SimpleLocalization.getText(ref, 'categoryName'),
                  hintText: SimpleLocalization.getText(ref, 'categoryName'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return SimpleLocalization.getText(
                      ref,
                      'categoryNameRequired',
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Tipo de categoría
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: SimpleLocalization.getText(ref, 'categoryType'),
                ),
                items: [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text(SimpleLocalization.getText(ref, 'income')),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text(SimpleLocalization.getText(ref, 'expense')),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
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
                filterCategory: 'category',
                title: SimpleLocalization.getText(ref, 'selectIcon'),
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Selector de color
              _buildColorSelector(theme),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(SimpleLocalization.getText(ref, 'cancel')),
        ),
        FilledButton(
          onPressed: _saveCategory,
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

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = Category(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        icon: IconUtils.getStringFromIcon(_selectedIcon),
        color: _selectedColor,
        type: _selectedType,
        createdAt: widget.category?.createdAt,
      );

      widget.onCategoryAdded(category);
      Navigator.pop(context);
    }
  }
}
