import 'package:hugeicons/styles/stroke_rounded.dart';
import 'icons_list.dart';

/// Utilidad centralizada para manejar iconos de HugeIcons
///
/// Este archivo contiene métodos para convertir entre strings y iconos.
/// La lista de iconos se encuentra en `icons_list.dart`.
class IconUtils {
  /// Lista completa de todos los iconos únicos disponibles en el proyecto
  /// (sin duplicados visuales)
  static final List<Map<String, dynamic>> allIcons = IconsList.getUniqueIcons();

  /// Obtener icono por nombre
  static List<List<dynamic>> getIconFromString(String iconString) {
    try {
      final iconData = allIcons.firstWhere(
        (icon) => icon['name'] == iconString,
        orElse: () => {'icon': HugeIconsStrokeRounded.tag01},
      );
      return iconData['icon'] as List<List<dynamic>>;
    } catch (e) {
      return HugeIconsStrokeRounded.tag01;
    }
  }

  /// Obtener nombre del icono
  static String getStringFromIcon(List<List<dynamic>> icon) {
    try {
      final iconData = allIcons.firstWhere(
        (iconData) => iconData['icon'] == icon,
        orElse: () => {'name': 'tag01'},
      );
      return iconData['name'] as String;
    } catch (e) {
      return 'tag01';
    }
  }

  /// Obtener iconos por categoría
  static List<Map<String, dynamic>> getIconsByCategory(String category) {
    return allIcons.where((icon) => icon['category'] == category).toList();
  }

  /// Obtener todas las categorías disponibles
  static List<String> getAvailableCategories() {
    return allIcons.map((icon) => icon['category'] as String).toSet().toList();
  }

  /// Obtener todos los iconos disponibles (sin duplicados visuales)
  static List<Map<String, dynamic>> getAllIcons() {
    return allIcons;
  }

  /// Obtener iconos para categorías de transacciones
  static List<Map<String, dynamic>> getCategoryIcons() {
    return allIcons
        .where(
          (icon) => [
            'shopping',
            'food',
            'transport',
            'entertainment',
            'health',
            'education',
            'work',
            'services',
            'finance',
          ].contains(icon['category']),
        )
        .toList();
  }

  /// Obtener iconos para suscripciones
  static List<Map<String, dynamic>> getSubscriptionIcons() {
    return allIcons
        .where(
          (icon) => [
            'entertainment',
            'services',
            'home',
            'health',
            'transport',
            'education',
            'food',
          ].contains(icon['category']),
        )
        .toList();
  }

  /// Verificar si un icono existe
  static bool iconExists(String iconName) {
    return allIcons.any((icon) => icon['name'] == iconName);
  }

  /// Obtener icono con fallback
  static List<List<dynamic>> getIconFromStringWithFallback(String iconString) {
    if (iconExists(iconString)) {
      return getIconFromString(iconString);
    } else {
      print('Icono no encontrado: $iconString, usando fallback');
      return HugeIconsStrokeRounded.tag01;
    }
  }
}
