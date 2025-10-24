import 'package:hugeicons/styles/stroke_rounded.dart';

/// Utilidad centralizada para manejar iconos de HugeIcons
///
/// Este archivo contiene todos los iconos disponibles en el proyecto
/// y métodos para convertir entre strings y iconos.
class IconUtils {
  /// Lista completa de todos los iconos disponibles en el proyecto
  static final List<Map<String, dynamic>> allIcons = [
    // Compras y hogar
    {
      'name': 'shoppingCart01',
      'icon': HugeIconsStrokeRounded.shoppingCart01,
      'category': 'shopping',
    },
    {
      'name': 'home07',
      'icon': HugeIconsStrokeRounded.home07,
      'category': 'home',
    },
    {
      'name': 'shoppingBag01',
      'icon': HugeIconsStrokeRounded.shoppingBag01,
      'category': 'shopping',
    },
    {
      'name': 'store01',
      'icon': HugeIconsStrokeRounded.store01,
      'category': 'shopping',
    },
    {
      'name': 'home01',
      'icon': HugeIconsStrokeRounded.home01,
      'category': 'home',
    },

    // Transporte
    {
      'name': 'car01',
      'icon': HugeIconsStrokeRounded.car01,
      'category': 'transport',
    },
    {
      'name': 'airplane01',
      'icon': HugeIconsStrokeRounded.airplane01,
      'category': 'transport',
    },
    {
      'name': 'bus01',
      'icon': HugeIconsStrokeRounded.bus01,
      'category': 'transport',
    },
    {
      'name': 'train01',
      'icon': HugeIconsStrokeRounded.train01,
      'category': 'transport',
    },

    // Comida y bebida
    {
      'name': 'food01',
      'icon': HugeIconsStrokeRounded.coffee01,
      'category': 'food',
    },
    {'name': 'drink', 'icon': HugeIconsStrokeRounded.drink, 'category': 'food'},
    {
      'name': 'restaurant01',
      'icon': HugeIconsStrokeRounded.restaurant01,
      'category': 'food',
    },
    {
      'name': 'pizza01',
      'icon': HugeIconsStrokeRounded.pizza01,
      'category': 'food',
    },
    {
      'name': 'coffee01',
      'icon': HugeIconsStrokeRounded.coffee01,
      'category': 'food',
    },

    // Entretenimiento
    {
      'name': 'entertainment01',
      'icon': HugeIconsStrokeRounded.gameController01,
      'category': 'entertainment',
    },
    {
      'name': 'basketball01',
      'icon': HugeIconsStrokeRounded.basketball01,
      'category': 'entertainment',
    },
    {
      'name': 'music01',
      'icon': HugeIconsStrokeRounded.speaker01,
      'category': 'entertainment',
    },
    {
      'name': 'movie01',
      'icon': HugeIconsStrokeRounded.video01,
      'category': 'entertainment',
    },
    {
      'name': 'tv01',
      'icon': HugeIconsStrokeRounded.tv01,
      'category': 'entertainment',
    },
    {
      'name': 'musicNote01',
      'icon': HugeIconsStrokeRounded.musicNote01,
      'category': 'entertainment',
    },
    {
      'name': 'computerDollar',
      'icon': HugeIconsStrokeRounded.computerDollar,
      'category': 'suscription',
    },

    // Salud y bienestar
    {
      'name': 'bodyPartMuscle',
      'icon': HugeIconsStrokeRounded.bodyPartMuscle,
      'category': 'health',
    },
    {
      'name': 'hospital01',
      'icon': HugeIconsStrokeRounded.hospital01,
      'category': 'health',
    },
    {
      'name': 'medicine01',
      'icon': HugeIconsStrokeRounded.medicine01,
      'category': 'health',
    },
    {
      'name': 'heart01',
      'icon': HugeIconsStrokeRounded.favourite,
      'category': 'health',
    },

    // Educación y trabajo
    {
      'name': 'education01',
      'icon': HugeIconsStrokeRounded.book01,
      'category': 'education',
    },
    {
      'name': 'idea01',
      'icon': HugeIconsStrokeRounded.idea01,
      'category': 'education',
    },
    {
      'name': 'briefcase01',
      'icon': HugeIconsStrokeRounded.briefcase01,
      'category': 'work',
    },
    {
      'name': 'laptop01',
      'icon': HugeIconsStrokeRounded.computer,
      'category': 'work',
    },
    {
      'name': 'book01',
      'icon': HugeIconsStrokeRounded.book01,
      'category': 'education',
    },

    // Servicios
    {
      'name': 'settings01',
      'icon': HugeIconsStrokeRounded.settings01,
      'category': 'services',
    },
    {
      'name': 'call01',
      'icon': HugeIconsStrokeRounded.call,
      'category': 'services',
    },
    {
      'name': 'wifi01',
      'icon': HugeIconsStrokeRounded.wifi01,
      'category': 'services',
    },
    {
      'name': 'electricity',
      'icon': HugeIconsStrokeRounded.location01,
      'category': 'services',
    },

    // Finanzas
    {
      'name': 'bitcoin01',
      'icon': HugeIconsStrokeRounded.bitcoin01,
      'category': 'finance',
    },
    {
      'name': 'wallet01',
      'icon': HugeIconsStrokeRounded.wallet01,
      'category': 'finance',
    },
    {
      'name': 'creditCard',
      'icon': HugeIconsStrokeRounded.creditCard,
      'category': 'finance',
    },
    {
      'name': 'bank',
      'icon': HugeIconsStrokeRounded.bank,
      'category': 'finance',
    },
    {
      'name': 'money01',
      'icon': HugeIconsStrokeRounded.money01,
      'category': 'finance',
    },
    {
      'name': 'cash01',
      'icon': HugeIconsStrokeRounded.cash01,
      'category': 'finance',
    },

    // Otros
    {
      'name': 'favourite',
      'icon': HugeIconsStrokeRounded.favourite,
      'category': 'general',
    },
    {
      'name': 'alms',
      'icon': HugeIconsStrokeRounded.alms,
      'category': 'general',
    },
    {
      'name': 'calendar',
      'icon': HugeIconsStrokeRounded.calendar01,
      'category': 'general',
    },
    {
      'name': 'gift',
      'icon': HugeIconsStrokeRounded.gift,
      'category': 'general',
    },
    {
      'name': 'tag01',
      'icon': HugeIconsStrokeRounded.tag01,
      'category': 'general',
    },
    {
      'name': 'building01',
      'icon': HugeIconsStrokeRounded.building01,
      'category': 'work',
    },
    {
      'name': 'arrowUp01',
      'icon': HugeIconsStrokeRounded.arrowUp01,
      'category': 'general',
    },
    {
      'name': 'arrowDown01',
      'icon': HugeIconsStrokeRounded.arrowDown01,
      'category': 'general',
    },
  ];

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
