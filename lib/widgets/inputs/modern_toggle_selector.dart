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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(3),
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
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: option.icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
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
