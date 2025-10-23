import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ModernToggleSelector<T> extends StatelessWidget {
  final T value;
  final List<ToggleOption<T>> options;
  final void Function(T) onChanged;

  const ModernToggleSelector({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((option) {
          return Expanded(
            child: _buildToggleOption(theme, option, value == option.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildToggleOption(
    ThemeData theme,
    ToggleOption<T> option,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onChanged(option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: option.icon,
              size: 20,
              color: isSelected
                  ? option.color
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? option.color
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToggleOption<T> {
  final T value;
  final String label;
  final List<List<dynamic>> icon;
  final Color color;

  const ToggleOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}
