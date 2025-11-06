import 'package:hive/hive.dart';

part 'app_config.g.dart';

@HiveType(typeId: 7)
class AppConfig extends HiveObject {
  @HiveField(0)
  final String currency;

  @HiveField(1)
  final String dateFormat;

  @HiveField(2)
  final String decimalSeparator;

  @HiveField(3)
  final bool showCents;

  @HiveField(4)
  final String theme;

  @HiveField(5)
  final String fontSize;

  @HiveField(6)
  final String language;

  @HiveField(7)
  final bool vibration;

  @HiveField(8)
  final bool sound;

  @HiveField(9)
  final int subscriptionReminderDays;

  @HiveField(10)
  final bool notificationsEnabled;

  @HiveField(11)
  final double monthlyExpenseLimit;

  @HiveField(12)
  final bool weeklySummary;

  @HiveField(13)
  final bool weekStartsOnMonday;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  @HiveField(16)
  final String? currentAccountId;

  AppConfig({
    this.currency = 'USD',
    this.dateFormat = 'DD/MM/YYYY',
    this.decimalSeparator = '.',
    this.showCents = true,
    this.theme = 'system',
    this.fontSize = 'normal',
    this.language = 'es',
    this.vibration = true,
    this.sound = true,
    this.subscriptionReminderDays = 1,
    this.notificationsEnabled = true,
    this.monthlyExpenseLimit = 0.0,
    this.weeklySummary = false,
    this.weekStartsOnMonday = true,
    this.currentAccountId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  AppConfig copyWith({
    String? currency,
    String? dateFormat,
    String? decimalSeparator,
    bool? showCents,
    String? theme,
    String? fontSize,
    String? language,
    bool? vibration,
    bool? sound,
    int? subscriptionReminderDays,
    bool? notificationsEnabled,
    double? monthlyExpenseLimit,
    bool? weeklySummary,
    bool? weekStartsOnMonday,
    String? currentAccountId,
  }) {
    return AppConfig(
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      showCents: showCents ?? this.showCents,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      vibration: vibration ?? this.vibration,
      sound: sound ?? this.sound,
      subscriptionReminderDays:
          subscriptionReminderDays ?? this.subscriptionReminderDays,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      monthlyExpenseLimit: monthlyExpenseLimit ?? this.monthlyExpenseLimit,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      weekStartsOnMonday: weekStartsOnMonday ?? this.weekStartsOnMonday,
      currentAccountId: currentAccountId ?? this.currentAccountId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'dateFormat': dateFormat,
      'decimalSeparator': decimalSeparator,
      'showCents': showCents,
      'theme': theme,
      'fontSize': fontSize,
      'language': language,
      'vibration': vibration,
      'sound': sound,
      'subscriptionReminderDays': subscriptionReminderDays,
      'notificationsEnabled': notificationsEnabled,
      'monthlyExpenseLimit': monthlyExpenseLimit,
      'weeklySummary': weeklySummary,
      'weekStartsOnMonday': weekStartsOnMonday,
      'currentAccountId': currentAccountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      currency: json['currency'] ?? 'USD',
      dateFormat: json['dateFormat'] ?? 'DD/MM/YYYY',
      decimalSeparator: json['decimalSeparator'] ?? '.',
      showCents: json['showCents'] ?? true,
      theme: json['theme'] ?? 'system',
      fontSize: json['fontSize'] ?? 'normal',
      language: json['language'] ?? 'es',
      vibration: json['vibration'] ?? true,
      sound: json['sound'] ?? true,
      subscriptionReminderDays: json['subscriptionReminderDays'] ?? 1,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      monthlyExpenseLimit: (json['monthlyExpenseLimit'] ?? 0.0).toDouble(),
      weeklySummary: json['weeklySummary'] ?? false,
      weekStartsOnMonday: json['weekStartsOnMonday'] ?? true,
      currentAccountId: json['currentAccountId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Enums para las opciones
@HiveType(typeId: 8)
enum Currency {
  @HiveField(0)
  usd,
  @HiveField(1)
  eur,
  @HiveField(2)
  mxn,
  @HiveField(3)
  gbp,
  @HiveField(4)
  cad,
  @HiveField(5)
  aud,
}

@HiveType(typeId: 9)
enum DateFormat {
  @HiveField(0)
  ddMMyyyy,
  @HiveField(1)
  mmDDyyyy,
  @HiveField(2)
  yyyyMMdd,
}

@HiveType(typeId: 10)
enum DecimalSeparator {
  @HiveField(0)
  dot,
  @HiveField(1)
  comma,
}

@HiveType(typeId: 11)
enum AppTheme {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}

@HiveType(typeId: 12)
enum FontSize {
  @HiveField(0)
  small,
  @HiveField(1)
  normal,
  @HiveField(2)
  large,
}

@HiveType(typeId: 13)
enum Language {
  @HiveField(0)
  es,
  @HiveField(1)
  en,
}
