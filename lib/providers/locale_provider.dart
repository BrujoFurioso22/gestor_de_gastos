import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/localization_service.dart';

/// Provider para el locale actual
final currentLocaleProvider = Provider<Locale>((ref) {
  // Usar un locale por defecto ya que no podemos usar WidgetRef aquí
  return const Locale('es', 'ES');
});

/// Provider para los locales soportados
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return LocalizationService.getSupportedLocales();
});
