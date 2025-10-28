import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_config.dart';
import '../services/hive_service.dart';

/// Provider para la configuración de la app
final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfig>((
  ref,
) {
  return AppConfigNotifier();
});

/// Provider para verificar si Hive está inicializado
final hiveInitializedProvider = FutureProvider<bool>((ref) async {
  try {
    // Intentar acceder a una caja existente para verificar si Hive está listo
    final box = HiveService.transactionsBox;
    return box.isOpen;
  } catch (e) {
    return false;
  }
});

class AppConfigNotifier extends StateNotifier<AppConfig> {
  AppConfigNotifier() : super(AppConfig());

  /// Carga la configuración desde Hive
  void _loadConfig() {
    try {
      state = HiveService.getAppConfig();
    } catch (e) {
      // Si Hive no está inicializado, usar configuración por defecto
      state = AppConfig();
    }
  }

  /// Actualiza la configuración
  Future<void> updateConfig(AppConfig newConfig) async {
    await HiveService.updateAppConfig(newConfig);
    state = newConfig;
  }

  /// Actualiza la moneda
  Future<void> updateCurrency(String currency) async {
    final newConfig = state.copyWith(currency: currency);
    await updateConfig(newConfig);
  }

  /// Actualiza el formato de fecha
  Future<void> updateDateFormat(String dateFormat) async {
    final newConfig = state.copyWith(dateFormat: dateFormat);
    await updateConfig(newConfig);
  }

  /// Actualiza el separador decimal
  Future<void> updateDecimalSeparator(String separator) async {
    final newConfig = state.copyWith(decimalSeparator: separator);
    await updateConfig(newConfig);
  }

  /// Actualiza si mostrar centavos
  Future<void> updateShowCents(bool showCents) async {
    final newConfig = state.copyWith(showCents: showCents);
    await updateConfig(newConfig);
  }

  /// Actualiza el tema
  Future<void> updateTheme(String theme) async {
    final newConfig = state.copyWith(theme: theme);
    await updateConfig(newConfig);
  }

  /// Actualiza el tamaño de fuente
  Future<void> updateFontSize(String fontSize) async {
    final newConfig = state.copyWith(fontSize: fontSize);
    await updateConfig(newConfig);
  }

  /// Actualiza el idioma
  Future<void> updateLanguage(String language) async {

    final newConfig = state.copyWith(language: language);
    await updateConfig(newConfig);

    // Actualizar traducciones de categorías por defecto
    await HiveService.updateCategoryTranslations(language);
  }

  /// Actualiza la vibración
  Future<void> updateVibration(bool vibration) async {
    final newConfig = state.copyWith(vibration: vibration);
    await updateConfig(newConfig);
  }

  /// Actualiza el sonido
  Future<void> updateSound(bool sound) async {
    final newConfig = state.copyWith(sound: sound);
    await updateConfig(newConfig);
  }

  /// Actualiza los días de recordatorio de suscripciones
  Future<void> updateSubscriptionReminderDays(int days) async {
    final newConfig = state.copyWith(subscriptionReminderDays: days);
    await updateConfig(newConfig);
  }

  /// Actualiza si las notificaciones están habilitadas
  Future<void> updateNotificationsEnabled(bool enabled) async {
    final newConfig = state.copyWith(notificationsEnabled: enabled);
    await updateConfig(newConfig);
  }

  /// Actualiza el límite mensual de gastos
  Future<void> updateMonthlyExpenseLimit(double limit) async {
    final newConfig = state.copyWith(monthlyExpenseLimit: limit);
    await updateConfig(newConfig);
  }

  /// Actualiza el resumen semanal
  Future<void> updateWeeklySummary(bool enabled) async {
    final newConfig = state.copyWith(weeklySummary: enabled);
    await updateConfig(newConfig);
  }

  /// Actualiza si la semana comienza en lunes
  Future<void> updateWeekStartsOnMonday(bool startsOnMonday) async {
    final newConfig = state.copyWith(weekStartsOnMonday: startsOnMonday);
    await updateConfig(newConfig);
  }

  /// Actualiza la cuenta actual
  Future<void> updateCurrentAccountId(String accountId) async {
    final newConfig = state.copyWith(currentAccountId: accountId);
    await updateConfig(newConfig);
  }

  /// Resetea la configuración a valores por defecto
  Future<void> resetToDefaults() async {
    final defaultConfig = AppConfig();
    await updateConfig(defaultConfig);
  }

  /// Inicializa la configuración después de que Hive esté listo
  void initializeConfig() {
    _loadConfig();
  }
}

/// Provider para obtener la moneda actual
final currencyProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).currency;
});

/// Provider para obtener el formato de fecha actual
final dateFormatProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).dateFormat;
});

/// Provider para obtener el separador decimal actual
final decimalSeparatorProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).decimalSeparator;
});

/// Provider para verificar si mostrar centavos
final showCentsProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).showCents;
});

/// Provider para obtener el tema actual
final themeProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).theme;
});

/// Provider para obtener el tamaño de fuente actual
final fontSizeProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).fontSize;
});

/// Provider para obtener el idioma actual
final languageProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).language;
});

/// Provider para verificar si la vibración está habilitada
final vibrationProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).vibration;
});

/// Provider para verificar si el sonido está habilitado
final soundProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).sound;
});
