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
    'income_bonuses',
    'income_rent',
    'income_refunds',
    'income_gifts',
    'income_online_sales',
    'income_interests',
    'income_savings_withdrawal',
    'income_asset_sale',
    'income_royalties',
    'income_business',
    'income_transfers_in',
    'income_other',
    'expense_food',
    'expense_coffee',
    'expense_utilities',
    'expense_housing',
    'expense_transport',
    'expense_fuel',
    'expense_education',
    'expense_health',
    'expense_medicine',
    'expense_gym',
    'expense_entertainment',
    'expense_games',
    'expense_shopping',
    'expense_clothing',
    'expense_subscriptions',
    'expense_personal_care',
    'expense_pets',
    'expense_travel',
    'expense_night_out',
    'expense_taxes',
    'expense_technology',
    'expense_apps',
    'expense_crypto',
    'expense_gifts',
    'expense_donations',
    'expense_repairs',
    'expense_vehicle_maintenance',
    'expense_debts',
    'expense_family',
    'expense_vacation',
    'expense_hobbies',
    'expense_self_development',
    'expense_business',
    'expense_bank_fees',
    'expense_other',
  ];

  // Traducciones de categorías por defecto
  static const Map<String, Map<String, String>> _categoryTranslations = {
    'income_salary': {'es': 'Salario', 'en': 'Salary'},
    'income_freelance': {'es': 'Freelance', 'en': 'Freelance'},
    'income_investment': {'es': 'Inversión', 'en': 'Investment'},
    'income_bonuses': {'es': 'Bonificaciones', 'en': 'Bonuses'},
    'income_rent': {'es': 'Alquiler', 'en': 'Rent Income'},
    'income_refunds': {'es': 'Reembolsos', 'en': 'Refunds'},
    'income_gifts': {'es': 'Regalos recibidos', 'en': 'Gifts Received'},
    'income_online_sales': {'es': 'Ventas en línea', 'en': 'Online Sales'},
    'income_interests': {'es': 'Intereses', 'en': 'Interests'},
    'income_savings_withdrawal': {
      'es': 'Ahorros retirados',
      'en': 'Savings Withdrawal',
    },
    'income_asset_sale': {'es': 'Venta de bienes', 'en': 'Asset Sale'},
    'income_royalties': {'es': 'Royalties', 'en': 'Royalties'},
    'income_business': {'es': 'Negocio propio', 'en': 'Business'},
    'income_transfers_in': {
      'es': 'Transferencias recibidas',
      'en': 'Transfers In',
    },
    'income_other': {'es': 'Otros', 'en': 'Others'},
    'expense_food': {'es': 'Alimentación', 'en': 'Food'},
    'expense_coffee': {'es': 'Cafetería', 'en': 'Coffee Shops'},
    'expense_utilities': {
      'es': 'Servicios (agua, luz, internet, etc.)',
      'en': 'Utilities',
    },
    'expense_housing': {'es': 'Vivienda / Arriendo', 'en': 'Housing / Rent'},
    'expense_transport': {'es': 'Transporte', 'en': 'Transport'},
    'expense_fuel': {'es': 'Gasolina', 'en': 'Fuel'},
    'expense_education': {'es': 'Educación', 'en': 'Education'},
    'expense_health': {'es': 'Salud', 'en': 'Health'},
    'expense_medicine': {'es': 'Medicinas', 'en': 'Medicine'},
    'expense_gym': {'es': 'Gimnasio / Fitness', 'en': 'Gym / Fitness'},
    'expense_entertainment': {'es': 'Entretenimiento', 'en': 'Entertainment'},
    'expense_games': {'es': 'Videojuegos', 'en': 'Games'},
    'expense_shopping': {'es': 'Compras', 'en': 'Shopping'},
    'expense_clothing': {'es': 'Ropa', 'en': 'Clothing'},
    'expense_subscriptions': {'es': 'Suscripciones', 'en': 'Subscriptions'},
    'expense_personal_care': {'es': 'Cuidado personal', 'en': 'Personal Care'},
    'expense_pets': {'es': 'Mascotas', 'en': 'Pets'},
    'expense_travel': {'es': 'Viajes', 'en': 'Travel'},
    'expense_night_out': {'es': 'Salidas / Bares', 'en': 'Night Out / Bars'},
    'expense_taxes': {'es': 'Impuestos', 'en': 'Taxes'},
    'expense_technology': {'es': 'Tecnología', 'en': 'Technology'},
    'expense_apps': {'es': 'Apps y software', 'en': 'Apps & Software'},
    'expense_crypto': {'es': 'Criptomonedas', 'en': 'Crypto'},
    'expense_gifts': {'es': 'Regalos', 'en': 'Gifts'},
    'expense_donations': {'es': 'Donaciones', 'en': 'Donations'},
    'expense_repairs': {'es': 'Reparaciones', 'en': 'Repairs'},
    'expense_vehicle_maintenance': {
      'es': 'Mantenimiento vehículo',
      'en': 'Vehicle Maintenance',
    },
    'expense_debts': {'es': 'Deudas / Créditos', 'en': 'Debts / Loans'},
    'expense_family': {'es': 'Hijos / Familia', 'en': 'Family & Kids'},
    'expense_vacation': {'es': 'Vacaciones', 'en': 'Vacation'},
    'expense_hobbies': {'es': 'Hobbies', 'en': 'Hobbies'},
    'expense_self_development': {
      'es': 'Desarrollo personal',
      'en': 'Self Development',
    },
    'expense_business': {'es': 'Negocios', 'en': 'Business Expenses'},
    'expense_bank_fees': {
      'es': 'Intereses bancarios',
      'en': 'Bank Fees / Interests',
    },
    'expense_other': {'es': 'Otros', 'en': 'Others'},
  };

  /// Obtiene el nombre traducido de una categoría por defecto
  static String getTranslatedName(String categoryId, String language) {
    final translations = _categoryTranslations[categoryId];
    if (translations == null) {
      return categoryId;
    }

    final result = language == 'en'
        ? (translations['en'] ?? translations['es'] ?? categoryId)
        : (translations['es'] ?? categoryId);

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
      icon: 'computer',
      color: '#90CAF9', // Azul pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_investment',
      name: 'Inversión',
      icon: 'money01',
      color: '#FFB74D', // Naranja pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_bonuses',
      name: 'Bonificaciones',
      icon: 'gift',
      color: '#F8BBD9', // Rosa pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_rent',
      name: 'Alquiler',
      icon: 'home01',
      color: '#B2EBF2', // Cian pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_refunds',
      name: 'Reembolsos',
      icon: 'creditCard',
      color: '#C5CAE9', // Índigo pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_gifts',
      name: 'Regalos recibidos',
      icon: 'gift',
      color: '#FFCDD2', // Rojo pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_online_sales',
      name: 'Ventas en línea',
      icon: 'shoppingCart01',
      color: '#D7CCC8', // Marrón pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_interests',
      name: 'Intereses',
      icon: 'money01',
      color: '#E1BEE7', // Púrpura pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_savings_withdrawal',
      name: 'Ahorros retirados',
      icon: 'wallet01',
      color: '#B0BEC5', // Gris pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_asset_sale',
      name: 'Venta de bienes',
      icon: 'car01',
      color: '#FFE0B2', // Naranja claro pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_royalties',
      name: 'Royalties',
      icon: 'tag01',
      color: '#A5D6A7', // Verde claro pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_business',
      name: 'Negocio propio',
      icon: 'store01',
      color: '#BCAAA4', // Marrón claro pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_transfers_in',
      name: 'Transferencias recibidas',
      icon: 'arrowDown01',
      color: '#9FA8DA', // Azul índigo pastel
      type: TransactionType.income,
    ),
    Category(
      id: 'income_other',
      name: 'Otros',
      icon: 'tag01',
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
      id: 'expense_coffee',
      name: 'Cafetería',
      icon: 'coffee01',
      color: '#D7CCC8', // Marrón pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_utilities',
      name: 'Servicios (agua, luz, internet, etc.)',
      icon: 'settings01',
      color: '#FFE082', // Amarillo pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_housing',
      name: 'Vivienda / Arriendo',
      icon: 'home01',
      color: '#B0BEC5', // Gris pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_transport',
      name: 'Transporte',
      icon: 'bus01',
      color: '#FFB74D', // Naranja pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_fuel',
      name: 'Gasolina',
      icon: 'car01',
      color: '#FFA726', // Naranja más oscuro
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_education',
      name: 'Educación',
      icon: 'book01',
      color: '#C5CAE9', // Índigo pastel
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
      id: 'expense_medicine',
      name: 'Medicinas',
      icon: 'medicine01',
      color: '#A5D6A7', // Verde claro pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_gym',
      name: 'Gimnasio / Fitness',
      icon: 'bodyPartMuscle',
      color: '#F48FB1', // Rosa pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_entertainment',
      name: 'Entretenimiento',
      icon: 'gameController01',
      color: '#F8BBD9', // Rosa pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_games',
      name: 'Videojuegos',
      icon: 'gameController01',
      color: '#BA68C8', // Púrpura pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_shopping',
      name: 'Compras',
      icon: 'shoppingBag01',
      color: '#D7CCC8', // Marrón pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_clothing',
      name: 'Ropa',
      icon: 'shoppingBag01',
      color: '#BCAAA4', // Marrón claro pastel
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
      id: 'expense_personal_care',
      name: 'Cuidado personal',
      icon: 'favourite',
      color: '#E1BEE7', // Púrpura pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_pets',
      name: 'Mascotas',
      icon: 'tag01',
      color: '#A5D6A7', // Verde claro pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_travel',
      name: 'Viajes',
      icon: 'airplane01',
      color: '#90CAF9', // Azul pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_night_out',
      name: 'Salidas / Bares',
      icon: 'drink',
      color: '#FF8A65', // Naranja rojizo pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_taxes',
      name: 'Impuestos',
      icon: 'creditCard',
      color: '#CE93D8', // Púrpura pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_technology',
      name: 'Tecnología',
      icon: 'computer',
      color: '#64B5F6', // Azul claro pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_apps',
      name: 'Apps y software',
      icon: 'computerDollar',
      color: '#4DD0E1', // Cian claro pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_crypto',
      name: 'Criptomonedas',
      icon: 'bitcoin01',
      color: '#FFB74D', // Naranja pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_gifts',
      name: 'Regalos',
      icon: 'gift',
      color: '#FFCDD2', // Rojo pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_donations',
      name: 'Donaciones',
      icon: 'favourite',
      color: '#EF5350', // Rojo más intenso
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_repairs',
      name: 'Reparaciones',
      icon: 'settings01',
      color: '#78909C', // Gris azulado
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_vehicle_maintenance',
      name: 'Mantenimiento vehículo',
      icon: 'car01',
      color: '#9E9E9E', // Gris medio
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_debts',
      name: 'Deudas / Créditos',
      icon: 'bank',
      color: '#795548', // Marrón
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_family',
      name: 'Hijos / Familia',
      icon: 'favourite',
      color: '#F48FB1', // Rosa pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_vacation',
      name: 'Vacaciones',
      icon: 'airplane01',
      color: '#81D4FA', // Azul cielo pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_hobbies',
      name: 'Hobbies',
      icon: 'tag01',
      color: '#AED581', // Verde lima pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_self_development',
      name: 'Desarrollo personal',
      icon: 'book01',
      color: '#7986CB', // Índigo pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_business',
      name: 'Negocios',
      icon: 'briefcase01',
      color: '#9575CD', // Púrpura medio pastel
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_bank_fees',
      name: 'Intereses bancarios',
      icon: 'bank',
      color: '#607D8B', // Gris azulado
      type: TransactionType.expense,
    ),
    Category(
      id: 'expense_other',
      name: 'Otros',
      icon: 'tag01',
      color: '#BDBDBD', // Gris claro
      type: TransactionType.expense,
    ),
  ];

  static List<Category> get allCategories => [
    ...incomeCategories,
    ...expenseCategories,
  ];
}
