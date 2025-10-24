import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'transaction.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final String color;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  Category({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Category copyWith({
    String? name,
    String? icon,
    String? color,
    TransactionType? type,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Categorías predefinidas
class DefaultCategories {
  // IDs de categorías por defecto (para identificar cuáles traducir)
  static const List<String> defaultCategoryIds = [
    'income_salary',
    'income_freelance',
    'income_investment',
    'income_other',
    'expense_food',
    'expense_subscriptions',
    'expense_transport',
    'expense_entertainment',
    'expense_health',
    'expense_education',
    'expense_shopping',
    'expense_bills',
    'expense_other',
  ];

  // Traducciones de categorías por defecto
  static const Map<String, Map<String, String>> _categoryTranslations = {
    'income_salary': {'es': 'Salario', 'en': 'Salary'},
    'income_freelance': {'es': 'Freelance', 'en': 'Freelance'},
    'income_investment': {'es': 'Inversión', 'en': 'Investment'},
    'income_other': {'es': 'Otros', 'en': 'Other'},
    'expense_food': {'es': 'Alimentación', 'en': 'Food'},
    'expense_subscriptions': {'es': 'Suscripciones', 'en': 'Subscriptions'},
    'expense_transport': {'es': 'Transporte', 'en': 'Transport'},
    'expense_entertainment': {'es': 'Entretenimiento', 'en': 'Entertainment'},
    'expense_health': {'es': 'Salud', 'en': 'Health'},
    'expense_education': {'es': 'Educación', 'en': 'Education'},
    'expense_shopping': {'es': 'Compras', 'en': 'Shopping'},
    'expense_bills': {'es': 'Servicios', 'en': 'Bills'},
    'expense_other': {'es': 'Otros', 'en': 'Other'},
  };

  /// Obtiene el nombre traducido de una categoría por defecto
  static String getTranslatedName(String categoryId, String language) {
    print('🔍 Buscando traducción para: $categoryId en idioma: $language');

    final translations = _categoryTranslations[categoryId];
    if (translations == null) {
      print('❌ No se encontraron traducciones para: $categoryId');
      return categoryId;
    }

    final result = language == 'en'
        ? (translations['en'] ?? translations['es'] ?? categoryId)
        : (translations['es'] ?? categoryId);

    print('✅ Traducción encontrada: $result');
    return result;
  }

  /// Verifica si una categoría es por defecto
  static bool isDefaultCategory(String categoryId) {
    return defaultCategoryIds.contains(categoryId);
  }

  static List<Category> get incomeCategories => [
    Category(
      id: 'income_salary',
      name: 'Salario',
      icon: 'briefcase01',
      color: '#81C784', // Verde pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_freelance',
      name: 'Freelance',
      icon: 'laptop01',
      color: '#90CAF9', // Azul pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_investment',
      name: 'Inversión',
      icon: 'wallet01',
      color: '#FFB74D', // Naranja pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_other',
      name: 'Otros',
      icon: 'bank',
      color: '#CE93D8', // Púrpura pastel
      type: TransactionType.income,
    ),
  ];

  static List<Category> get expenseCategories => [
    Category(
      id: 'expense_food',
      name: 'Alimentación',
      icon: 'restaurant01',
      color: '#FFCDD2', // Rojo pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_subscriptions',
      name: 'Suscripciones',
      icon: 'computerDollar',
      color: '#81C784', // Verde pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_transport',
      name: 'Transporte',
      icon: 'car01',
      color: '#FFE0B2', // Naranja pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_entertainment',
      name: 'Entretenimiento',
      icon: 'entertainment01',
      color: '#F8BBD9', // Rosa pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_health',
      name: 'Salud',
      icon: 'hospital01',
      color: '#B2EBF2', // Cian pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_education',
      name: 'Educación',
      icon: 'education01',
      color: '#C5CAE9', // Índigo pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_shopping',
      name: 'Compras',
      icon: 'shoppingCart01',
      color: '#D7CCC8', // Marrón pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_bills',
      name: 'Servicios',
      icon: 'home07',
      color: '#B0BEC5', // Gris pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_other',
      name: 'Otros',
      icon: 'food01',
      color: '#E1BEE7', // Púrpura pastel
      type: TransactionType.expense,
    ),
  ];

  static List<Category> get allCategories => [
    ...incomeCategories,
    ...expenseCategories,
  ];
}
