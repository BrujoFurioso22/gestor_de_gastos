import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/hive_service.dart';

/// Provider para la configuración de la app
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});

/// Provider para el tema oscuro
final isDarkModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.isDarkMode;
});

/// Provider para el estado premium
final isPremiumProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.isPremium;
});

/// Provider para la moneda
final currencyProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.currency;
});

/// Provider para el idioma
final languageProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.language;
});

/// Provider para el contador de aperturas de la app
final appOpenCountProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.appOpenCount;
});

/// Provider para verificar si se debe mostrar un anuncio
final shouldShowAdProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return !settings.isPremium &&
      settings.appOpenCount > 0 &&
      settings.appOpenCount % 5 == 0;
});

/// Notifier para manejar la configuración de la app
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  /// Carga la configuración desde Hive
  void _loadSettings() {
    state = HiveService.getAppSettings();
  }

  /// Actualiza la configuración
  Future<void> updateSettings(AppSettings newSettings) async {
    await HiveService.saveAppSettings(newSettings);
    state = newSettings;
  }

  /// Cambia el tema (claro/oscuro)
  Future<void> toggleTheme() async {
    final newSettings = state.copyWith(isDarkMode: !state.isDarkMode);
    await updateSettings(newSettings);
  }

  /// Establece el tema
  Future<void> setTheme(bool isDarkMode) async {
    final newSettings = state.copyWith(isDarkMode: isDarkMode);
    await updateSettings(newSettings);
  }

  /// Cambia el estado premium
  Future<void> togglePremium() async {
    final newSettings = state.copyWith(isPremium: !state.isPremium);
    await updateSettings(newSettings);
  }

  /// Establece el estado premium
  Future<void> setPremium(bool isPremium) async {
    final newSettings = state.copyWith(isPremium: isPremium);
    await updateSettings(newSettings);
  }

  /// Cambia la moneda
  Future<void> setCurrency(String currency) async {
    final newSettings = state.copyWith(currency: currency);
    await updateSettings(newSettings);
  }

  /// Cambia el idioma
  Future<void> setLanguage(String language) async {
    final newSettings = state.copyWith(language: language);
    await updateSettings(newSettings);
  }

  /// Incrementa el contador de aperturas de la app
  Future<void> incrementAppOpenCount() async {
    final newSettings = state.copyWith(appOpenCount: state.appOpenCount + 1);
    await updateSettings(newSettings);
  }

  /// Establece el tiempo del último anuncio mostrado
  Future<void> setLastAdShown(DateTime time) async {
    final newSettings = state.copyWith(lastAdShown: time);
    await updateSettings(newSettings);
  }

  /// Resetea la configuración a los valores por defecto
  Future<void> resetToDefaults() async {
    final defaultSettings = AppSettings();
    await updateSettings(defaultSettings);
  }

  /// Refresca la configuración
  void refresh() {
    _loadSettings();
  }

  /// Obtiene el tiempo transcurrido desde el último anuncio
  Duration get timeSinceLastAd {
    return DateTime.now().difference(state.lastAdShown);
  }

  /// Verifica si ha pasado suficiente tiempo para mostrar otro anuncio
  bool get canShowAd {
    return timeSinceLastAd.inHours >= 1; // 1 hora de cooldown
  }

  /// Verifica si se debe mostrar un anuncio basado en la frecuencia
  bool shouldShowAd() {
    return !state.isPremium &&
        state.appOpenCount > 0 &&
        state.appOpenCount % 5 == 0 &&
        canShowAd;
  }
}
