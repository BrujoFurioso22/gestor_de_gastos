import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_config_provider.dart';

class LocalizationService {
  /// Obtiene el locale actual basado en la configuración del usuario
  static Locale getCurrentLocale(WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    switch (appConfig.language) {
      case 'es':
        return const Locale('es', 'ES');
      case 'en':
        return const Locale('en', 'US');
      default:
        return const Locale('es', 'ES');
    }
  }

  /// Obtiene la lista de locales soportados
  static List<Locale> getSupportedLocales() {
    return const [Locale('es', 'ES'), Locale('en', 'US')];
  }

  /// Obtiene el nombre del idioma para mostrar en la UI
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }

  /// Obtiene el código del idioma desde el locale
  static String getLanguageCodeFromLocale(Locale locale) {
    return locale.languageCode;
  }
}
