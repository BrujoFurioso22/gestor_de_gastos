import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ModernIconPrefix extends StatelessWidget {
  final List<List<dynamic>> icon;
  final double size;
  final Color? color;

  const ModernIconPrefix({
    super.key,
    required this.icon,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(12),
      child: Center(
        child: HugeIcon(
          icon: icon,
          size: size,
          color: color ?? theme.colorScheme.primary,
        ),
      ),
    );
  }
}
