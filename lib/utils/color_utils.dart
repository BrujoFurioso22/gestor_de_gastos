import 'package:flutter/material.dart';

class ColorUtils {
  /// Convierte un string hexadecimal a Color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Agregar alpha si no está presente
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Convierte un Color a string hexadecimal
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Obtiene el color de contraste (blanco o negro) para un color de fondo
  static Color getContrastColor(Color backgroundColor) {
    // Calcular la luminancia del color de fondo
    final luminance = backgroundColor.computeLuminance();
    // Si la luminancia es mayor a 0.5, usar negro, sino blanco
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Crea un color con opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Crea un color más claro
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  /// Crea un color más oscuro
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Genera un color basado en un string (útil para avatares)
  static Color generateColorFromString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return Color(hash & 0x00FFFFFF).withOpacity(1.0);
  }

  /// Obtiene colores de categoría predefinidos
  static List<Color> get categoryColors => [
    const Color(0xFFF44336), // Rojo
    const Color(0xFFE91E63), // Rosa
    const Color(0xFF9C27B0), // Púrpura
    const Color(0xFF673AB7), // Púrpura oscuro
    const Color(0xFF3F51B5), // Índigo
    const Color(0xFF2196F3), // Azul
    const Color(0xFF03A9F4), // Azul claro
    const Color(0xFF00BCD4), // Cian
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Verde
    const Color(0xFF8BC34A), // Verde claro
    const Color(0xFFCDDC39), // Lima
    const Color(0xFFFFEB3B), // Amarillo
    const Color(0xFFFFC107), // Ámbar
    const Color(0xFFFF9800), // Naranja
    const Color(0xFFFF5722), // Naranja profundo
    const Color(0xFF795548), // Marrón
    const Color(0xFF607D8B), // Azul gris
    const Color(0xFF9E9E9E), // Gris
    const Color(0xFF424242), // Gris oscuro
  ];

  /// Obtiene un color de categoría por índice
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  /// Verifica si un color es claro
  static bool isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// Verifica si un color es oscuro
  static bool isDarkColor(Color color) {
    return color.computeLuminance() <= 0.5;
  }
}
