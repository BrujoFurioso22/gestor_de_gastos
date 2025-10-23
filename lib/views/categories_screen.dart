import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/category_provider.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../widgets/forms/category_form.dart';
import '../widgets/inputs/custom_floating_action_button.dart';
import '../utils/icon_utils.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalization.getText(ref, 'manageCategories')),
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIconsStrokeRounded.arrowLeft01),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: categories.isEmpty
          ? _buildEmptyState(context, ref, theme)
          : _buildCategoriesList(context, ref, categories, theme),
      floatingActionButton: AddFloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIconsStrokeRounded.folder01,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            SimpleLocalization.getText(ref, 'noCategories'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            SimpleLocalization.getText(ref, 'addFirstCategory'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(context, ref),
            icon: const HugeIcon(icon: HugeIconsStrokeRounded.add01, size: 20),
            label: Text(SimpleLocalization.getText(ref, 'addCategory')),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
    ThemeData theme,
  ) {
    // Separar categorías por tipo
    final incomeCategories = categories
        .where((category) => category.type == TransactionType.income)
        .toList();
    final expenseCategories = categories
        .where((category) => category.type == TransactionType.expense)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categorías de Ingresos
          if (incomeCategories.isNotEmpty) ...[
            _buildCategorySection(
              context,
              ref,
              SimpleLocalization.getText(ref, 'income'),
              incomeCategories,
              theme,
            ),
            const SizedBox(height: AppConstants.largePadding),
          ],

          // Categorías de Gastos
          if (expenseCategories.isNotEmpty) ...[
            _buildCategorySection(
              context,
              ref,
              SimpleLocalization.getText(ref, 'expenses'),
              expenseCategories,
              theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<Category> categories,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ...categories.map(
          (category) => _buildCategoryCard(context, ref, category, theme),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    Category category,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            int.parse(category.color.replaceFirst('#', '0xFF')),
          ),
          child: HugeIcon(
            icon: IconUtils.getIconFromString(category.icon),
            size: 20,
            color: Colors.white,
          ),
        ),
        title: Text(category.name),
        subtitle: Text(
          SimpleLocalization.getText(ref, category.type.name),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleCategoryAction(context, ref, value, category),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const HugeIcon(icon: HugeIconsStrokeRounded.edit01, size: 20),
                  const SizedBox(width: 8),
                  Text(SimpleLocalization.getText(ref, 'editCategory')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIconsStrokeRounded.delete01,
                    size: 20,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    SimpleLocalization.getText(ref, 'deleteCategory'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCategoryAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Category category,
  ) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(context, ref, category);
        break;
      case 'delete':
        _showDeleteCategoryDialog(context, ref, category);
        break;
    }
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryFormPage(isEdit: false),
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategoryFormPage(category: category, isEdit: true),
      ),
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
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
              ref.read(categoriesProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    SimpleLocalization.getText(ref, 'categoryDeleted'),
                  ),
                ),
              );
            },
            child: Text(SimpleLocalization.getText(ref, 'delete')),
          ),
        ],
      ),
    );
  }
}
