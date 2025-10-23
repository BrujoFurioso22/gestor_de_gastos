import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/subscription.dart';
import '../../utils/app_formatters.dart';
import '../../constants/app_constants.dart';

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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.withOpacity(0.2)
              : isDueSoon
              ? Colors.orange.withOpacity(0.2)
              : theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              subscription.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 10),
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
                        const SizedBox(height: 6),
                        Text(
                          subscription.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Botón de menú flotante moderno
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showModernActionMenu(context, theme),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.moreVertical,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),


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
                      HugeIcon(
                        icon: isOverdue
                            ? HugeIconsStrokeRounded.alert01
                            : HugeIconsStrokeRounded.clock01,
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
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.note,
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

  void _showModernActionMenu(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIconsStrokeRounded.menu11,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acciones',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Gestiona tu suscripción',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Opciones del menú
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // Pausar/Reanudar
                  _buildMenuOption(
                    context: context,
                    theme: theme,
                    icon: subscription.isActive
                        ? HugeIconsStrokeRounded.pause
                        : HugeIconsStrokeRounded.play,
                    title: subscription.isActive ? 'Pausar' : 'Reanudar',
                    subtitle: subscription.isActive
                        ? 'Detener temporalmente'
                        : 'Reactivar suscripción',
                    color: subscription.isActive ? Colors.orange : Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      onToggleStatus?.call();
                    },
                  ),

                  // Marcar como pagada (solo si está activa)
                  if (subscription.isActive)
                    _buildMenuOption(
                      context: context,
                      theme: theme,
                      icon: HugeIconsStrokeRounded.tick01,
                      title: 'Marcar como pagada',
                      subtitle: 'Registrar pago realizado',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        onMarkAsPaid?.call();
                      },
                    ),

                  // Eliminar
                  _buildMenuOption(
                    context: context,
                    theme: theme,
                    icon: HugeIconsStrokeRounded.delete01,
                    title: 'Eliminar',
                    subtitle: 'Eliminar permanentemente',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      onDelete?.call();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required ThemeData theme,
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: HugeIcon(icon: icon, size: 20, color: color),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              HugeIcon(
                icon: HugeIconsStrokeRounded.arrowRight02,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
