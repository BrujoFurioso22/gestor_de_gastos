import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../constants/app_constants.dart';

class IconSelectorWidget extends ConsumerStatefulWidget {
  final List<List<dynamic>> selectedIcon;
  final Function(List<List<dynamic>>) onIconChanged;
  final String? filterCategory;
  final String title;

  const IconSelectorWidget({
    super.key,
    required this.selectedIcon,
    required this.onIconChanged,
    this.filterCategory,
    this.title = 'Seleccionar icono',
  });

  @override
  ConsumerState<IconSelectorWidget> createState() => _IconSelectorWidgetState();
}

class _IconSelectorWidgetState extends ConsumerState<IconSelectorWidget> {
  // Iconos para categorías - HugeIcons stroke rounded
  static final List<Map<String, dynamic>> _categoryIcons = [
    // Gastos comunes - HugeIcons stroke rounded
    {
      'icon': HugeIconsStrokeRounded.shoppingCart01,
      'name': 'Compras',
      'category': 'shopping',
    },
    {
      'icon': HugeIconsStrokeRounded.restaurant01,
      'name': 'Comida',
      'category': 'food',
    },
    {
      'icon': HugeIconsStrokeRounded.home01,
      'name': 'Hogar',
      'category': 'home',
    },
    {
      'icon': HugeIconsStrokeRounded.car01,
      'name': 'Transporte',
      'category': 'transport',
    },
    {
      'icon': HugeIconsStrokeRounded.book01,
      'name': 'Educación',
      'category': 'education',
    },
    {
      'icon': HugeIconsStrokeRounded.hospital01,
      'name': 'Salud',
      'category': 'health',
    },
    {
      'icon': HugeIconsStrokeRounded.airplane01,
      'name': 'Viajes',
      'category': 'travel',
    },
    {
      'icon': HugeIconsStrokeRounded.coffee01,
      'name': 'Café',
      'category': 'food',
    },
    {
      'icon': HugeIconsStrokeRounded.money01,
      'name': 'Dinero',
      'category': 'finance',
    },
    {
      'icon': HugeIconsStrokeRounded.wallet01,
      'name': 'Billetera',
      'category': 'finance',
    },
    {
      'icon': HugeIconsStrokeRounded.cash01,
      'name': 'Efectivo',
      'category': 'finance',
    },
  ];

  // Iconos para suscripciones - HugeIcons stroke rounded
  static final List<Map<String, dynamic>> _subscriptionIcons = [
    // Servicios básicos
    {
      'icon': HugeIconsStrokeRounded.tv01,
      'name': 'TV',
      'category': 'entertainment',
    },
    {
      'icon': HugeIconsStrokeRounded.musicNote01,
      'name': 'Música',
      'category': 'entertainment',
    },
    {
      'icon': HugeIconsStrokeRounded.home01,
      'name': 'Hogar',
      'category': 'home',
    },
    {
      'icon': HugeIconsStrokeRounded.hospital01,
      'name': 'Salud',
      'category': 'health',
    },
    {
      'icon': HugeIconsStrokeRounded.car01,
      'name': 'Auto',
      'category': 'transport',
    },
    {
      'icon': HugeIconsStrokeRounded.book01,
      'name': 'Educación',
      'category': 'education',
    },
    {
      'icon': HugeIconsStrokeRounded.coffee01,
      'name': 'Café',
      'category': 'food',
    },
    {
      'icon': HugeIconsStrokeRounded.restaurant01,
      'name': 'Restaurante',
      'category': 'food',
    },
    {
      'icon': HugeIconsStrokeRounded.shoppingCart01,
      'name': 'Compras',
      'category': 'shopping',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableIcons = _getAvailableIcons();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        SizedBox(
          height: 120,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = availableIcons[index];
              final icon = iconData['icon'] as List<List<dynamic>>;
              final isSelected = icon == widget.selectedIcon;

              return GestureDetector(
                onTap: () {
                  widget.onIconChanged(icon);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: icon,
                      size: 24,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getAvailableIcons() {
    if (widget.filterCategory == 'subscription') {
      return _subscriptionIcons;
    } else if (widget.filterCategory == 'category') {
      return _categoryIcons;
    }
    return _categoryIcons; // Default
  }
}

// Clase utilitaria para manejar iconos
class IconUtils {
  // Mapeo de strings a IconData para compatibilidad con datos existentes
  static final Map<String, List<List<dynamic>>> _iconMap = {
    // Categorías de Ingresos - HugeIcons stroke rounded
    'work': HugeIconsStrokeRounded.briefcase01,
    'business': HugeIconsStrokeRounded.building01,
    'trending_up': HugeIconsStrokeRounded.arrowUp01,
    'money': HugeIconsStrokeRounded.money01,

    // Categorías de Gastos - HugeIcons stroke rounded
    'restaurant': HugeIconsStrokeRounded.restaurant01,
    'car': HugeIconsStrokeRounded.car01,
    'tv': HugeIconsStrokeRounded.tv01,
    'hospital': HugeIconsStrokeRounded.hospital01,
    'book': HugeIconsStrokeRounded.book01,
    'shopping_cart': HugeIconsStrokeRounded.shoppingCart01,
    'home': HugeIconsStrokeRounded.home01,
    'coffee': HugeIconsStrokeRounded.coffee01,

    // Iconos adicionales para compatibilidad
    'directions_car': HugeIconsStrokeRounded.car01,
    'local_hospital': HugeIconsStrokeRounded.hospital01,
    'flight': HugeIconsStrokeRounded.airplane01,
    'local_cafe': HugeIconsStrokeRounded.coffee01,
    'attach_money': HugeIconsStrokeRounded.money01,
    'wallet': HugeIconsStrokeRounded.wallet01,
    'account_balance_wallet': HugeIconsStrokeRounded.cash01,
    'music_note': HugeIconsStrokeRounded.musicNote01,
  };

  static List<List<dynamic>> getIconFromString(String iconString) {
    // Mapeo con iconos específicos para cada categoría
    switch (iconString) {
      // Categorías de Ingresos
      case 'briefcase':
        return HugeIconsStrokeRounded.briefcase01;
      case 'laptop':
        return HugeIconsStrokeRounded.building01;
      case 'trending_up':
        return HugeIconsStrokeRounded.arrowUp01;
      case 'money':
        return HugeIconsStrokeRounded.money01;

      // Categorías de Gastos
      case 'restaurant':
        return HugeIconsStrokeRounded.restaurant01;
      case 'car':
        return HugeIconsStrokeRounded.car01;
      case 'tv':
        return HugeIconsStrokeRounded.tv01;
      case 'hospital':
        return HugeIconsStrokeRounded.hospital01;
      case 'book':
        return HugeIconsStrokeRounded.book01;
      case 'shopping_cart':
        return HugeIconsStrokeRounded.shoppingCart01;
      case 'home':
        return HugeIconsStrokeRounded.home01;
      case 'coffee':
        return HugeIconsStrokeRounded.coffee01;

      // Compatibilidad con iconos antiguos
      case 'work':
        return HugeIconsStrokeRounded.briefcase01;
      case 'business':
        return HugeIconsStrokeRounded.building01;

      default:
        return HugeIconsStrokeRounded.tag01;
    }
  }

  static String getStringFromIcon(List<List<dynamic>> icon) {
    // Crear mapeo inverso para convertir icono a string
    for (final entry in _iconMap.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }
    return 'shopping_cart'; // Fallback
  }
}
