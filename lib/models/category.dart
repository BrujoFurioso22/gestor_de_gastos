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
