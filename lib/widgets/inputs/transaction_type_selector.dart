import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/transaction.dart';
import '../../services/simple_localization.dart';
import 'modern_toggle_selector.dart';

/// Componente reutilizable para seleccionar el tipo de transacción (Income/Expense)
class TransactionTypeSelector extends ConsumerWidget {
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ModernToggleSelector<TransactionType>(
      value: value,
      options: [
        ToggleOption(
          value: TransactionType.income,
          label: SimpleLocalization.getText(ref, 'income'),
          icon: HugeIconsStrokeRounded.arrowUp01,
          color: theme.colorScheme.primary,
        ),
        ToggleOption(
          value: TransactionType.expense,
          label: SimpleLocalization.getText(ref, 'expense'),
          icon: HugeIconsStrokeRounded.arrowDown01,
          color: theme.colorScheme.error,
        ),
      ],
      onChanged: onChanged,
    );
  }
}

