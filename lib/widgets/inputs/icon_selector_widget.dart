import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../constants/app_constants.dart';
import '../../utils/icon_utils.dart';

/// Widget para seleccionar iconos de HugeIcons
///
/// Ejemplo de uso:
/// ```dart
/// // Para obtener un icono desde un string:
/// final icon = IconUtils.getIconFromString('food01');
///
/// // Para obtener el string de un icono:
/// final iconString = IconUtils.getStringFromIcon(HugeIconsStrokeRounded.food01);
/// ```

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
      return IconUtils.getSubscriptionIcons();
    } else if (widget.filterCategory == 'category') {
      return IconUtils.getCategoryIcons();
    }
    return IconUtils.getCategoryIcons(); // Default
  }
}
