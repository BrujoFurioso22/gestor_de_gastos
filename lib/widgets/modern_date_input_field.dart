import 'package:flutter/material.dart';
import 'modern_icon_prefix.dart';

class ModernDateInputField extends StatelessWidget {
  final DateTime value;
  final String label;
  final String hint;
  final List<List<dynamic>> icon;
  final Future<DateTime?> Function() onTap;
  final String? Function(DateTime?)? validator;
  final bool enabled;

  const ModernDateInputField({
    super.key,
    required this.value,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: ModernIconPrefix(icon: icon),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          child: Text(
            '${value.day}/${value.month}/${value.year}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
