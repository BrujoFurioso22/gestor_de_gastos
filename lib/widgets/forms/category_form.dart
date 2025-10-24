import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../services/simple_localization.dart';
import '../../constants/app_constants.dart';
import '../../utils/icon_utils.dart';
import '../inputs/modern_toggle_selector.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  final Category? category;
  final bool isEdit;

  const CategoryFormPage({super.key, this.category, this.isEdit = false});

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String _selectedIcon = 'shoppingCart01';
  String _selectedColor = '#FFCDD2'; // Rojo pastel por defecto
  bool _isDefaultCategory = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.category != null) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    final category = widget.category!;
    _nameController.text = category.name;
    _selectedType = category.type;
    _selectedIcon = category.icon;
    _selectedColor = category.color;
    _isDefaultCategory = DefaultCategories.isDefaultCategory(category.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit
              ? SimpleLocalization.getText(ref, 'editCategory')
              : SimpleLocalization.getText(ref, 'addCategory'),
        ),
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIconsStrokeRounded.arrowLeft01),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveCategory,
            child: Text(
              widget.isEdit
                  ? SimpleLocalization.getText(ref, 'update')
                  : SimpleLocalization.getText(ref, 'save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                enabled:
                    !_isDefaultCategory, // Deshabilitar para categorías por defecto
                decoration: InputDecoration(
                  labelText:
                      '${SimpleLocalization.getText(ref, 'categoryName')} *',
                  hintText: _isDefaultCategory
                      ? 'Nombre fijo (se traduce automáticamente)'
                      : SimpleLocalization.getText(ref, 'categoryNameHint'),
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

              // Mensaje informativo para categorías por defecto
              if (_isDefaultCategory) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.alertCircle,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta es una categoría por defecto. Solo puedes cambiar el ícono y el color. El nombre se traduce automáticamente.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
              ] else
                const SizedBox(height: AppConstants.defaultPadding),

              // Type selector
              _buildTypeSelector(theme),

              const SizedBox(height: AppConstants.defaultPadding),

              // Icon selector
              _buildIconSelector(theme),

              const SizedBox(height: AppConstants.defaultPadding),

              // Color selector
              _buildColorSelector(theme),

              const SizedBox(height: AppConstants.largePadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${SimpleLocalization.getText(ref, 'categoryType')} *',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing:
              _isDefaultCategory, // Deshabilitar para categorías por defecto
          child: Opacity(
            opacity: _isDefaultCategory ? 0.5 : 1.0,
            child: ModernToggleSelector<TransactionType>(
              options: [
                ToggleOption(
                  value: TransactionType.expense,
                  label: SimpleLocalization.getText(ref, 'expense'),
                  color: theme.colorScheme.error,
                  icon: HugeIconsStrokeRounded.arrowDown01,
                ),
                ToggleOption(
                  value: TransactionType.income,
                  label: SimpleLocalization.getText(ref, 'income'),
                  color: theme.colorScheme.primary,
                  icon: HugeIconsStrokeRounded.arrowUp01,
                ),
              ],
              value: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
          ),
        ),
        if (_isDefaultCategory) ...[
          const SizedBox(height: 8),
          Text(
            'Tipo fijo (no se puede cambiar)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIconSelector(ThemeData theme) {
    final iconData = IconUtils.getCategoryIcons();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          SimpleLocalization.getText(ref, 'selectIcon'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260, // Aumenté la altura para dar más espacio a los iconos
          child: GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, // Más columnas para más iconos
              crossAxisSpacing: 6, // Un poco más de espacio entre iconos
              mainAxisSpacing: 6, // Un poco más de espacio vertical
              childAspectRatio:
                  0.9, // Reducir el aspect ratio para iconos más altos
            ),
            itemCount: iconData.length,
            itemBuilder: (context, index) {
              final iconInfo = iconData[index];
              final isSelected = _selectedIcon == iconInfo['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = iconInfo['name'] as String;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: HugeIcon(
                    icon: iconInfo['icon'] as List<List<dynamic>>,
                    color: isSelected ? theme.colorScheme.onPrimary : null,
                    size: 24, // Aumentar el tamaño del icono
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector(ThemeData theme) {
    final colors = [
      // Rojos y rosas
      '#FFCDD2', '#F8BBD9', '#FCE4EC', '#FFB3BA', '#FFCCCB',

      // Púrpuras y violetas
      '#E1BEE7', '#D1C4E9', '#C5CAE9', '#B39DDB', '#9C27B0',

      // Azules
      '#BBDEFB', '#B3E5FC', '#81D4FA', '#4FC3F7', '#29B6F6',
      '#03A9F4', '#2196F3', '#1976D2', '#1565C0', '#0D47A1',

      // Verdes
      '#B2DFDB', '#C8E6C9', '#DCEDC8', '#A5D6A7', '#81C784',
      '#66BB6A', '#4CAF50', '#388E3C', '#2E7D32', '#1B5E20',

      // Amarillos y naranjas
      '#F0F4C3', '#FFF9C4', '#FFECB3', '#FFE0B2', '#FFCC80',
      '#FFB74D', '#FF9800', '#F57C00', '#E65100', '#BF360C',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          SimpleLocalization.getText(ref, 'selectColor'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210, // Aumentar la altura para dar más espacio
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calcular el número de columnas basado en el ancho disponible
              const itemSize = 40.0; // Tamaño de cada color
              const spacing = 8.0; // Espacio entre elementos
              final crossAxisCount =
                  ((constraints.maxWidth + spacing) / (itemSize + spacing))
                      .floor();

              return GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 1,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final color = colors[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(color.replaceFirst('#', '0xFF')),
                        ),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? HugeIcon(
                              icon: HugeIconsStrokeRounded.tick01,
                              color: theme.colorScheme.onPrimary,
                              size: 20, // Ícono más grande
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();

      if (widget.isEdit && widget.category != null) {
        // Update existing category
        final updatedCategory = widget.category!.copyWith(
          name: name,
          type: _selectedType,
          icon: _selectedIcon,
          color: _selectedColor,
        );

        ref.read(categoriesProvider.notifier).updateCategory(updatedCategory);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SimpleLocalization.getText(ref, 'categoryUpdated')),
          ),
        );
      } else {
        // Create new category
        final newCategory = Category(
          name: name,
          type: _selectedType,
          icon: _selectedIcon,
          color: _selectedColor,
        );

        ref.read(categoriesProvider.notifier).addCategory(newCategory);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SimpleLocalization.getText(ref, 'categoryAdded')),
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}
