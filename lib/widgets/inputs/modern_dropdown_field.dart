import 'package:flutter/material.dart';
import 'modern_icon_prefix.dart';

class ModernDropdownField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final String hint;
  final List<List<dynamic>> icon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const ModernDropdownField({
    super.key,
    this.value,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    this.onChanged,
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
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: ModernIconPrefix(icon: icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: items,
        onChanged: enabled ? onChanged : null,
        validator: validator,
      ),
    );
  }
}
