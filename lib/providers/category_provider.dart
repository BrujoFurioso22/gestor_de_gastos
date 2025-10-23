import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/hive_service.dart';
import 'transaction_provider.dart';

/// Provider para todas las categorías
final categoriesProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
      return CategoryNotifier();
    });

/// Provider para categorías de ingresos
final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories
      .where((category) => category.type == TransactionType.income)
      .toList();
});

/// Provider para categorías de gastos
final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories
      .where((category) => category.type == TransactionType.expense)
      .toList();
});

/// Provider para obtener una categoría por ID
final categoryByIdProvider = Provider.family<Category?, String>((
  ref,
  categoryId,
) {
  final categories = ref.watch(categoriesProvider);
  try {
    return categories.firstWhere((category) => category.id == categoryId);
  } catch (e) {
    return null;
  }
});

/// Provider para categorías con estadísticas
final categoriesWithStatsProvider = Provider<List<CategoryWithStats>>((ref) {
  final categories = ref.watch(categoriesProvider);
  final transactions = ref.watch(transactionsProvider);

  return categories.map((category) {
    final categoryTransactions = transactions
        .where((transaction) => transaction.category == category.id)
        .toList();

    final totalAmount = categoryTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
    final transactionCount = categoryTransactions.length;

    return CategoryWithStats(
      category: category,
      totalAmount: totalAmount,
      transactionCount: transactionCount,
    );
  }).toList();
});

/// Provider para categorías de ingresos con estadísticas
final incomeCategoriesWithStatsProvider = Provider<List<CategoryWithStats>>((
  ref,
) {
  final categoriesWithStats = ref.watch(categoriesWithStatsProvider);
  return categoriesWithStats
      .where(
        (categoryStats) =>
            categoryStats.category.type == TransactionType.income,
      )
      .toList();
});

/// Provider para categorías de gastos con estadísticas
final expenseCategoriesWithStatsProvider = Provider<List<CategoryWithStats>>((
  ref,
) {
  final categoriesWithStats = ref.watch(categoriesWithStatsProvider);
  return categoriesWithStats
      .where(
        (categoryStats) =>
            categoryStats.category.type == TransactionType.expense,
      )
      .toList();
});

/// Notifier para manejar las categorías
class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    _loadCategories();
  }

  /// Carga todas las categorías desde Hive
  void _loadCategories() {
    state = HiveService.getAllCategories();
  }

  /// Agrega una nueva categoría
  Future<void> addCategory(Category category) async {
    await HiveService.categoriesBox.put(category.id, category);
    _loadCategories();
  }

  /// Actualiza una categoría existente
  Future<void> updateCategory(Category category) async {
    await HiveService.categoriesBox.put(category.id, category);
    _loadCategories();
  }

  /// Elimina una categoría
  Future<void> deleteCategory(String categoryId) async {
    await HiveService.categoriesBox.delete(categoryId);
    _loadCategories();
  }

  /// Obtiene una categoría por ID
  Category? getCategory(String categoryId) {
    return HiveService.categoriesBox.get(categoryId);
  }

  /// Refresca la lista de categorías
  void refresh() {
    _loadCategories();
  }

  /// Obtiene categorías por tipo
  List<Category> getCategoriesByType(TransactionType type) {
    return state.where((category) => category.type == type).toList();
  }

  /// Busca categorías por nombre
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return state;

    final lowercaseQuery = query.toLowerCase();
    return state
        .where(
          (category) => category.name.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }
}

/// Clase que combina una categoría con sus estadísticas
class CategoryWithStats {
  final Category category;
  final double totalAmount;
  final int transactionCount;

  const CategoryWithStats({
    required this.category,
    required this.totalAmount,
    required this.transactionCount,
  });

  /// Calcula el porcentaje de uso de esta categoría
  double getPercentage(List<CategoryWithStats> allCategories) {
    if (allCategories.isEmpty) return 0.0;

    final totalAmount = allCategories.fold(
      0.0,
      (sum, cat) => sum + cat.totalAmount,
    );
    if (totalAmount == 0) return 0.0;

    return (totalAmount / totalAmount) * 100;
  }
}

/// Provider para el filtro de categorías
final categoryFilterProvider = StateProvider<TransactionType?>((ref) => null);

/// Provider para categorías filtradas
final filteredCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoriesProvider);
  final filter = ref.watch(categoryFilterProvider);

  if (filter == null) return categories;

  return categories.where((category) => category.type == filter).toList();
});
