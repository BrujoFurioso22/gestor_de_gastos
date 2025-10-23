import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../utils/app_formatters.dart';
import '../constants/app_constants.dart';

class SubscriptionCard extends ConsumerWidget {
  final Subscription subscription;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onDelete;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
    this.onToggleStatus,
    this.onMarkAsPaid,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOverdue = subscription.isOverdue;
    final isDueSoon = subscription.isDueSoon;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre, estado y acciones
              Row(
                children: [
                  // Icono
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getColorFromHex(
                        subscription.color,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallBorderRadius,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        subscription.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),

                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subscription.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: subscription.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                subscription.isActive ? 'Activa' : 'Inactiva',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: subscription.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subscription.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menú de acciones
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'toggle':
                          onToggleStatus?.call();
                          break;
                        case 'mark_paid':
                          onMarkAsPaid?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              subscription.isActive
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(subscription.isActive ? 'Pausar' : 'Reanudar'),
                          ],
                        ),
                      ),
                      if (subscription.isActive)
                        const PopupMenuItem(
                          value: 'mark_paid',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text('Marcar como pagada'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Información de pago
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentInfo(
                      theme,
                      'Costo',
                      AppFormatters.formatCurrency(subscription.amount, ref),
                      subscription.frequency.shortName,
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentInfo(
                      theme,
                      'Próximo pago',
                      AppFormatters.formatDate(
                        subscription.nextPaymentDate,
                        ref,
                      ),
                      _getDaysUntilPayment(),
                    ),
                  ),
                ],
              ),

              // Alertas
              if (isOverdue || isDueSoon) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                    border: Border.all(
                      color: isOverdue ? Colors.red : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOverdue ? Icons.warning : Icons.schedule,
                        color: isOverdue ? Colors.red : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isOverdue ? 'Pago vencido' : 'Pago próximo a vencer',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Notas (si existen)
              if (subscription.notes != null &&
                  subscription.notes!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subscription.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(
    ThemeData theme,
    String label,
    String value,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getDaysUntilPayment() {
    final now = DateTime.now();
    final days = subscription.nextPaymentDate.difference(now).inDays;

    if (days < 0) {
      return 'Vencido';
    } else if (days == 0) {
      return 'Hoy';
    } else if (days == 1) {
      return 'Mañana';
    } else {
      return '$days días';
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Color por defecto
    }
  }
}
