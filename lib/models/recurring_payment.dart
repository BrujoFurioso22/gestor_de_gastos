import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../services/simple_localization.dart';
import 'transaction.dart';

part 'recurring_payment.g.dart';

@HiveType(typeId: 14)
class RecurringPayment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final RecurringFrequency frequency;

  @HiveField(5)
  final TransactionType type; // expense o income

  @HiveField(6)
  final String category; // ID de la categoría

  @HiveField(7)
  final int dayOfMonth; // Día del mes (1-31, 0 para frecuencia no mensual)

  @HiveField(8)
  final DateTime startDate;

  @HiveField(9)
  final DateTime? endDate;

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final String icon;

  @HiveField(12)
  final String color;

  @HiveField(13)
  final bool isActive;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  @HiveField(16)
  final DateTime nextPaymentDate;

  @HiveField(17)
  final String? accountId;

  RecurringPayment({
    String? id,
    required this.name,
    this.description,
    required this.amount,
    required this.frequency,
    required this.type,
    required this.category,
    int? dayOfMonth,
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
       // Calcular día del mes desde la fecha de inicio si no se proporciona
       dayOfMonth =
           dayOfMonth ??
           ((frequency == RecurringFrequency.monthly ||
                   frequency == RecurringFrequency.quarterly ||
                   frequency == RecurringFrequency.yearly)
               ? startDate.day
               : 0),
       nextPaymentDate =
           nextPaymentDate ??
           _calculateNextPayment(
             startDate,
             frequency,
             dayOfMonth ??
                 ((frequency == RecurringFrequency.monthly ||
                         frequency == RecurringFrequency.quarterly ||
                         frequency == RecurringFrequency.yearly)
                     ? startDate.day
                     : 0),
           );

  RecurringPayment copyWith({
    String? name,
    String? description,
    double? amount,
    RecurringFrequency? frequency,
    TransactionType? type,
    String? category,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? nextPaymentDate,
    String? accountId,
  }) {
    final newFrequency = frequency ?? this.frequency;
    final newStartDate = startDate ?? this.startDate;
    // Calcular día del mes desde la fecha de inicio si no se proporciona
    final calculatedDayOfMonth =
        dayOfMonth ??
        ((newFrequency == RecurringFrequency.monthly ||
                newFrequency == RecurringFrequency.quarterly ||
                newFrequency == RecurringFrequency.yearly)
            ? newStartDate.day
            : this.dayOfMonth);

    return RecurringPayment(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      frequency: newFrequency,
      type: type ?? this.type,
      category: category ?? this.category,
      dayOfMonth: calculatedDayOfMonth,
      startDate: newStartDate,
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
            newStartDate,
            newFrequency,
            calculatedDayOfMonth,
          ),
    );
  }

  /// Calcula la próxima fecha de pago
  static DateTime _calculateNextPayment(
    DateTime startDate,
    RecurringFrequency frequency,
    int dayOfMonth,
  ) {
    final now = DateTime.now();
    DateTime nextPayment = startDate;

    while (nextPayment.isBefore(now) || nextPayment.isAtSameMomentAs(now)) {
      switch (frequency) {
        case RecurringFrequency.daily:
          nextPayment = nextPayment.add(const Duration(days: 1));
          break;
        case RecurringFrequency.weekly:
          nextPayment = nextPayment.add(const Duration(days: 7));
          break;
        case RecurringFrequency.monthly:
          // Usar el día del mes especificado
          if (dayOfMonth > 0) {
            nextPayment = DateTime(
              nextPayment.year,
              nextPayment.month + 1,
              dayOfMonth > 28
                  ? 28 // Ajustar para meses con menos días
                  : dayOfMonth,
            );
          } else {
            // Si no hay día específico, usar el mismo día del mes siguiente
            nextPayment = DateTime(
              nextPayment.year,
              nextPayment.month + 1,
              nextPayment.day,
            );
          }
          break;
        case RecurringFrequency.quarterly:
          if (dayOfMonth > 0) {
            nextPayment = DateTime(
              nextPayment.year,
              nextPayment.month + 3,
              dayOfMonth > 28 ? 28 : dayOfMonth,
            );
          } else {
            nextPayment = DateTime(
              nextPayment.year,
              nextPayment.month + 3,
              nextPayment.day,
            );
          }
          break;
        case RecurringFrequency.yearly:
          if (dayOfMonth > 0) {
            nextPayment = DateTime(
              nextPayment.year + 1,
              nextPayment.month,
              dayOfMonth > 28 ? 28 : dayOfMonth,
            );
          } else {
            nextPayment = DateTime(
              nextPayment.year + 1,
              nextPayment.month,
              nextPayment.day,
            );
          }
          break;
      }
    }

    return nextPayment;
  }

  /// Verifica si el pago está próximo a vencer (en los próximos 7 días)
  bool get isDueSoon {
    final now = DateTime.now();
    final daysUntilPayment = nextPaymentDate.difference(now).inDays;
    return daysUntilPayment <= 7 && daysUntilPayment >= 0;
  }

  /// Verifica si el pago está vencido
  bool get isOverdue {
    return nextPaymentDate.isBefore(DateTime.now());
  }

  /// Verifica si el pago recurrente ha expirado
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
      'type': type.name,
      'category': category,
      'dayOfMonth': dayOfMonth,
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

  factory RecurringPayment.fromJson(Map<String, dynamic> json) {
    return RecurringPayment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => RecurringFrequency.monthly,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      category: json['category'],
      dayOfMonth: json['dayOfMonth'] ?? 0,
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

@HiveType(typeId: 15)
enum RecurringFrequency {
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

extension RecurringFrequencyExtension on RecurringFrequency {
  String get displayName {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Diario';
      case RecurringFrequency.weekly:
        return 'Semanal';
      case RecurringFrequency.monthly:
        return 'Mensual';
      case RecurringFrequency.quarterly:
        return 'Trimestral';
      case RecurringFrequency.yearly:
        return 'Anual';
    }
  }

  String get shortName {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Día';
      case RecurringFrequency.weekly:
        return 'Sem';
      case RecurringFrequency.monthly:
        return 'Mes';
      case RecurringFrequency.quarterly:
        return 'Trim';
      case RecurringFrequency.yearly:
        return 'Año';
    }
  }

  String getTranslatedShortName(WidgetRef ref) {
    switch (this) {
      case RecurringFrequency.daily:
        return SimpleLocalization.getText(ref, 'frequencyShortDay');
      case RecurringFrequency.weekly:
        return SimpleLocalization.getText(ref, 'frequencyShortWeek');
      case RecurringFrequency.monthly:
        return SimpleLocalization.getText(ref, 'frequencyShortMonth');
      case RecurringFrequency.quarterly:
        return SimpleLocalization.getText(ref, 'frequencyShortQuarter');
      case RecurringFrequency.yearly:
        return SimpleLocalization.getText(ref, 'frequencyShortYear');
    }
  }
}
