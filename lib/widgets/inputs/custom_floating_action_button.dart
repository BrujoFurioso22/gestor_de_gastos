import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

/// Widget reutilizable para botones flotantes personalizados
class CustomFloatingActionButton extends StatelessWidget {
  /// Icono del botón
  final List<List<dynamic>> icon;

  /// Texto del label (opcional)
  final String? label;

  /// Tamaño del icono
  final double iconSize;

  /// Función a ejecutar al presionar
  final VoidCallback onPressed;

  /// Color de fondo del botón
  final Color? backgroundColor;

  /// Color del icono
  final Color? iconColor;

  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.iconSize = 24,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Si tiene label, usar FloatingActionButton.extended
    if (label != null && label!.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: iconColor ?? theme.colorScheme.onPrimary,
        icon: HugeIcon(
          icon: icon,
          size: iconSize,
          color: iconColor ?? theme.colorScheme.onPrimary,
        ),
        label: Text(
          label!,
          style: theme.textTheme.labelLarge?.copyWith(
            color: iconColor ?? theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Si no tiene label, usar FloatingActionButton normal
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: iconColor ?? theme.colorScheme.onPrimary,
      child: HugeIcon(
        icon: icon,
        size: iconSize,
        color: iconColor ?? theme.colorScheme.onPrimary,
      ),
    );
  }
}

/// Widgets predefinidos para casos comunes
class AddFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final double iconSize;

  const AddFloatingActionButton({
    super.key,
    required this.onPressed,
    this.label,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFloatingActionButton(
      icon: HugeIconsStrokeRounded.add01,
      onPressed: onPressed,
      label: label,
      iconSize: iconSize,
    );
  }
}

class EditFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final double iconSize;

  const EditFloatingActionButton({
    super.key,
    required this.onPressed,
    this.label,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFloatingActionButton(
      icon: HugeIconsStrokeRounded.edit01,
      onPressed: onPressed,
      label: label,
      iconSize: iconSize,
    );
  }
}

class SaveFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final double iconSize;

  const SaveFloatingActionButton({
    super.key,
    required this.onPressed,
    this.label,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFloatingActionButton(
      icon: HugeIconsStrokeRounded.tick01,
      onPressed: onPressed,
      label: label,
      iconSize: iconSize,
    );
  }
}
