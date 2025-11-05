import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../constants/app_constants.dart';
import '../../utils/icon_utils.dart';
import '../../services/simple_localization.dart';

class IconSelectorPage extends ConsumerStatefulWidget {
  final String selectedIcon;

  const IconSelectorPage({super.key, required this.selectedIcon});

  @override
  ConsumerState<IconSelectorPage> createState() => _IconSelectorPageState();
}

class _IconSelectorPageState extends ConsumerState<IconSelectorPage> {
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = IconUtils.getAllIcons();

    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalization.getText(ref, 'selectIcon')),
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIconsStrokeRounded.arrowLeft01),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: iconData.length,
        // Asegurar que se rendericen todos los items
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          final iconInfo = iconData[index];
          final iconName = iconInfo['name'] as String;
          final isSelected = _selectedIcon == iconName;

          return InkWell(
            onTap: () {
              // Seleccionar y volver automáticamente
              Navigator.pop(context, iconName);
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: HugeIcon(
                  icon: iconInfo['icon'] as List<List<dynamic>>,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                  size: 32,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
