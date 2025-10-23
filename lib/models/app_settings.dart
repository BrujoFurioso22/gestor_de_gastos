import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final bool isPremium;

  @HiveField(2)
  final String currency;

  @HiveField(3)
  final String language;

  @HiveField(4)
  final int appOpenCount;

  @HiveField(5)
  final DateTime lastAdShown;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  AppSettings({
    this.isDarkMode = false,
    this.isPremium = false,
    this.currency = 'EUR',
    this.language = 'es',
    this.appOpenCount = 0,
    DateTime? lastAdShown,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : lastAdShown =
           lastAdShown ?? DateTime.now().subtract(const Duration(hours: 1)),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  AppSettings copyWith({
    bool? isDarkMode,
    bool? isPremium,
    String? currency,
    String? language,
    int? appOpenCount,
    DateTime? lastAdShown,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isPremium: isPremium ?? this.isPremium,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      appOpenCount: appOpenCount ?? this.appOpenCount,
      lastAdShown: lastAdShown ?? this.lastAdShown,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'isPremium': isPremium,
      'currency': currency,
      'language': language,
      'appOpenCount': appOpenCount,
      'lastAdShown': lastAdShown.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      isPremium: json['isPremium'] ?? false,
      currency: json['currency'] ?? 'EUR',
      language: json['language'] ?? 'es',
      appOpenCount: json['appOpenCount'] ?? 0,
      lastAdShown: DateTime.parse(json['lastAdShown']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
