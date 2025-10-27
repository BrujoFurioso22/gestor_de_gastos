import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_config_provider.dart';

part 'subscription.g.dart';

@HiveType(typeId: 5)
class Subscription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final SubscriptionFrequency frequency;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final String icon;

  @HiveField(9)
  final String color;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final DateTime nextPaymentDate;

  @HiveField(14)
  final String? accountId;

  Subscription({
    String? id,
    required this.name,
    required this.description,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.icon,
    required this.color,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextPaymentDate,
    this.accountId,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       nextPaymentDate =
           nextPaymentDate ?? _calculateNextPayment(startDate, frequency);

  Subscription copyWith({
    String? name,
    String? description,
    double? amount,
    SubscriptionFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? nextPaymentDate,
    String? accountId,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      nextPaymentDate:
          nextPaymentDate ??
          _calculateNextPayment(
            startDate ?? this.startDate,
            frequency ?? this.frequency,
          ),
    );
  }

  /// Calcula la próxima fecha de pago
  static DateTime _calculateNextPayment(
    DateTime startDate,
    SubscriptionFrequency frequency,
  ) {
    final now = DateTime.now();
    DateTime nextPayment = startDate;

    while (nextPayment.isBefore(now) || nextPayment.isAtSameMomentAs(now)) {
      switch (frequency) {
        case SubscriptionFrequency.daily:
          nextPayment = nextPayment.add(const Duration(days: 1));
          break;
        case SubscriptionFrequency.weekly:
          nextPayment = nextPayment.add(const Duration(days: 7));
          break;
        case SubscriptionFrequency.monthly:
          nextPayment = DateTime(
            nextPayment.year,
            nextPayment.month + 1,
            nextPayment.day,
          );
          break;
        case SubscriptionFrequency.quarterly:
          nextPayment = DateTime(
            nextPayment.year,
            nextPayment.month + 3,
            nextPayment.day,
          );
          break;
        case SubscriptionFrequency.yearly:
          nextPayment = DateTime(
            nextPayment.year + 1,
            nextPayment.month,
            nextPayment.day,
          );
          break;
      }
    }

    return nextPayment;
  }

  /// Calcula el costo anual de la suscripción
  double get yearlyCost {
    switch (frequency) {
      case SubscriptionFrequency.daily:
        return amount * 365;
      case SubscriptionFrequency.weekly:
        return amount * 52;
      case SubscriptionFrequency.monthly:
        return amount * 12;
      case SubscriptionFrequency.quarterly:
        return amount * 4;
      case SubscriptionFrequency.yearly:
        return amount;
    }
  }

  /// Calcula el costo mensual promedio
  double get monthlyCost {
    return yearlyCost / 12;
  }

  /// Verifica si la suscripción está próxima a vencer (en los próximos 7 días)
  bool get isDueSoon {
    final now = DateTime.now();
    final daysUntilPayment = nextPaymentDate.difference(now).inDays;
    return daysUntilPayment <= 7 && daysUntilPayment >= 0;
  }

  /// Verifica si la suscripción está vencida
  bool get isOverdue {
    return nextPaymentDate.isBefore(DateTime.now());
  }

  /// Verifica si la suscripción ha expirado (fecha de fin ya pasó)
  bool get isExpired {
    return endDate != null && endDate!.isBefore(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'icon': icon,
      'color': color,
      'isActive': isActive,
      'accountId': accountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      frequency: SubscriptionFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => SubscriptionFrequency.monthly,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      notes: json['notes'],
      icon: json['icon'],
      color: json['color'],
      isActive: json['isActive'] ?? true,
      accountId: json['accountId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate']),
    );
  }
}

@HiveType(typeId: 6)
enum SubscriptionFrequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  quarterly,

  @HiveField(4)
  yearly,
}

extension SubscriptionFrequencyExtension on SubscriptionFrequency {
  String get displayName {
    switch (this) {
      case SubscriptionFrequency.daily:
        return 'Diario';
      case SubscriptionFrequency.weekly:
        return 'Semanal';
      case SubscriptionFrequency.monthly:
        return 'Mensual';
      case SubscriptionFrequency.quarterly:
        return 'Trimestral';
      case SubscriptionFrequency.yearly:
        return 'Anual';
    }
  }

  String get shortName {
    switch (this) {
      case SubscriptionFrequency.daily:
        return 'Día';
      case SubscriptionFrequency.weekly:
        return 'Sem';
      case SubscriptionFrequency.monthly:
        return 'Mes';
      case SubscriptionFrequency.quarterly:
        return 'Trim';
      case SubscriptionFrequency.yearly:
        return 'Año';
    }
  }

  String getTranslatedShortName(WidgetRef ref) {
    final isEnglish = ref.read(appConfigProvider).language == 'en';

    switch (this) {
      case SubscriptionFrequency.daily:
        return isEnglish ? 'Day' : 'Día';
      case SubscriptionFrequency.weekly:
        return isEnglish ? 'Week' : 'Sem';
      case SubscriptionFrequency.monthly:
        return isEnglish ? 'Month' : 'Mes';
      case SubscriptionFrequency.quarterly:
        return isEnglish ? 'Qtr' : 'Trim';
      case SubscriptionFrequency.yearly:
        return isEnglish ? 'Year' : 'Año';
    }
  }
}

// Suscripciones predefinidas populares
class DefaultSubscriptions {
  static List<Subscription> get popularSubscriptions => [
    Subscription(
      id: 'netflix',
      name: 'Netflix',
      description: 'Streaming de películas y series',
      amount: 15.99,
      frequency: SubscriptionFrequency.monthly,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      icon: '🎬',
      color: '#E50914',
    ),
    Subscription(
      id: 'spotify',
      name: 'Spotify',
      description: 'Música y podcasts',
      amount: 9.99,
      frequency: SubscriptionFrequency.monthly,
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      icon: '🎵',
      color: '#1DB954',
    ),
    Subscription(
      id: 'amazon_prime',
      name: 'Amazon Prime',
      description: 'Envíos gratis y streaming',
      amount: 14.99,
      frequency: SubscriptionFrequency.monthly,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      icon: '📦',
      color: '#00A8E1',
    ),
    Subscription(
      id: 'disney_plus',
      name: 'Disney+',
      description: 'Contenido de Disney, Marvel y Star Wars',
      amount: 8.99,
      frequency: SubscriptionFrequency.monthly,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      icon: '🏰',
      color: '#113CCF',
    ),
    Subscription(
      id: 'adobe_creative',
      name: 'Adobe Creative Cloud',
      description: 'Suite de diseño y edición',
      amount: 52.99,
      frequency: SubscriptionFrequency.monthly,
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      icon: '🎨',
      color: '#FF0000',
    ),
    Subscription(
      id: 'office_365',
      name: 'Microsoft 365',
      description: 'Office y almacenamiento en la nube',
      amount: 6.99,
      frequency: SubscriptionFrequency.monthly,
      startDate: DateTime.now().subtract(const Duration(days: 12)),
      icon: '📊',
      color: '#0078D4',
    ),
  ];
}
