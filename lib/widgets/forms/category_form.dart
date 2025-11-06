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
import '../inputs/transaction_type_selector.dart';
import '../selectors/icon_selector_page.dart';
import '../selectors/color_selector_page.dart';

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${SimpleLocalization.getText(ref, 'categoryName')} *',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    enabled:
                        !_isDefaultCategory, // Deshabilitar para categorías por defecto
                    decoration: InputDecoration(
                      hintText: _isDefaultCategory
                          ? 'Nombre fijo (se traduce automáticamente)'
                          : SimpleLocalization.getText(ref, 'categoryNameHint'),
                      filled: true,
                      fillColor: _isDefaultCategory
                          ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                          : theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: theme.textTheme.bodyLarge,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return SimpleLocalization.getText(ref, 'nameRequired');
                      }
                      return null;
                    },
                  ),
                ],
              ),

              // Mensaje informativo para categorías por defecto
              if (_isDefaultCategory) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                          icon: HugeIconsStrokeRounded.alertCircle,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Esta es una categoría por defecto. Solo puedes cambiar el ícono y el color. El nombre se traduce automáticamente.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            height: 1.4,
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

              // Botón de eliminar (solo en modo edición)
              if (widget.isEdit &&
                  widget.category != null &&
                  !_isDefaultCategory) ...[
                const SizedBox(height: AppConstants.largePadding),
                Divider(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                InkWell(
                  onTap: () => _showDeleteCategoryDialog(context, ref),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.delete01,
                          size: 22,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          SimpleLocalization.getText(ref, 'deleteCategory'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
              ] else
                const SizedBox(height: AppConstants.largePadding),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'deleteCategory')),
        content: Text(SimpleLocalization.getText(ref, 'deleteCategoryConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (widget.category != null) {
                ref
                    .read(categoriesProvider.notifier)
                    .deleteCategory(widget.category!.id);
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Cerrar formulario
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      SimpleLocalization.getText(ref, 'categoryDeleted'),
                    ),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(SimpleLocalization.getText(ref, 'delete')),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${SimpleLocalization.getText(ref, 'categoryType')} *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        AbsorbPointer(
          absorbing:
              _isDefaultCategory, // Deshabilitar para categorías por defecto
          child: Opacity(
            opacity: _isDefaultCategory ? 0.5 : 1.0,
            child: TransactionTypeSelector(
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
    final selectedIconData = IconUtils.getIconFromString(_selectedIcon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${SimpleLocalization.getText(ref, 'selectIcon')} *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    IconSelectorPage(selectedIcon: _selectedIcon),
              ),
            );

            if (result != null) {
              setState(() {
                _selectedIcon = result;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: selectedIconData,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    SimpleLocalization.getText(ref, 'selectIcon'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                HugeIcon(
                  icon: HugeIconsStrokeRounded.arrowRight01,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector(ThemeData theme) {
    final selectedColorValue = Color(
      int.parse(_selectedColor.replaceFirst('#', '0xFF')),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${SimpleLocalization.getText(ref, 'selectColor')} *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ColorSelectorPage(selectedColor: _selectedColor),
              ),
            );

            if (result != null) {
              setState(() {
                _selectedColor = result;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: selectedColorValue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColorValue.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    SimpleLocalization.getText(ref, 'selectColor'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                HugeIcon(
                  icon: HugeIconsStrokeRounded.arrowRight01,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
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
