import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../models/recurring_payment.dart';
import '../../models/transaction.dart';
import '../../utils/app_formatters.dart';
import '../../utils/icon_utils.dart';
import '../../constants/app_constants.dart';
import '../../services/simple_localization.dart';

class RecurringPaymentCard extends ConsumerWidget {
  final RecurringPayment payment;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const RecurringPaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOverdue = payment.isOverdue;
    final isDueSoon = payment.isDueSoon;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
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
                  // Icono
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(payment.color.replaceFirst('#', '0xFF')),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: HugeIcon(
                      icon: IconUtils.getIconFromString(payment.icon),
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                payment.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: payment.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                payment.isActive
                                    ? SimpleLocalization.getText(ref, 'active')
                                    : SimpleLocalization.getText(
                                        ref,
                                        'inactive',
                                      ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: payment.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (payment.description != null &&
                            payment.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            payment.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
                        onTap: () => _showModernActionMenu(context, theme, ref),
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

              const SizedBox(height: AppConstants.smallPadding),

              // Información de pago
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentInfo(
                      theme,
                      SimpleLocalization.getText(ref, 'amount'),
                      AppFormatters.formatCurrency(payment.amount, ref),
                      payment.frequency.getTranslatedShortName(ref),
                      payment.type == TransactionType.income
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentInfo(
                      theme,
                      SimpleLocalization.getText(ref, 'nextPayment'),
                      AppFormatters.formatDate(payment.nextPaymentDate, ref),
                      _getDaysUntilPayment(ref),
                      isOverdue
                          ? Colors.red
                          : isDueSoon
                              ? Colors.orange
                              : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Advertencias de vencimiento
              if (isOverdue || isDueSoon) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: (isOverdue ? Colors.red : Colors.orange)
                        .withOpacity(0.1),
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
                        icon: HugeIconsStrokeRounded.alert01,
                        color: isOverdue ? Colors.red : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isOverdue
                              ? SimpleLocalization.getText(ref, 'overdue')
                              : SimpleLocalization.getText(ref, 'dueSoon'),
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

              // Información de fecha de fin si existe
              if (payment.endDate != null) ...[
                const SizedBox(height: AppConstants.smallPadding),
                _buildEndDateWarning(context, theme, ref),
              ],

              // Notas (si existen)
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
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
                          payment.notes!,
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
    Color valueColor,
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
            color: valueColor,
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

  String _getDaysUntilPayment(WidgetRef ref) {
    final now = DateTime.now();
    final days = payment.nextPaymentDate.difference(now).inDays;

    if (days == 0) {
      return SimpleLocalization.getText(ref, 'today');
    } else if (days == 1) {
      return SimpleLocalization.getText(ref, 'tomorrow');
    } else if (days < 0) {
      return '${-days} ${SimpleLocalization.getText(ref, 'daysAgo')}';
    } else {
      return '${SimpleLocalization.getText(ref, 'inDays').replaceAll('X', '$days')}';
    }
  }

  Widget _buildEndDateWarning(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    if (payment.endDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final endDate = DateTime(
      payment.endDate!.year,
      payment.endDate!.month,
      payment.endDate!.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    final daysUntilEnd = endDate.difference(today).inDays;

    // Determinar color y mensaje según qué tan cerca esté de expirar
    Color warningColor;
    String message;
    List<List<dynamic>> icon;

    if (daysUntilEnd < 0) {
      // Ya expiró pero aún no se ha pausado
      warningColor = Colors.grey;
      message = SimpleLocalization.getText(ref, 'finished');
      icon = HugeIconsStrokeRounded.alert01;
    } else if (daysUntilEnd == 0) {
      // Expira hoy
      warningColor = Colors.red;
      message = SimpleLocalization.getText(ref, 'endsToday');
      icon = HugeIconsStrokeRounded.alert01;
    } else if (daysUntilEnd <= 7) {
      // Expira en los próximos 7 días
      warningColor = Colors.orange;
      final dayText = daysUntilEnd == 1
          ? SimpleLocalization.getText(ref, 'day')
          : SimpleLocalization.getText(ref, 'days');
      message =
          '${SimpleLocalization.getText(ref, 'endsInDays').replaceAll('X', '$daysUntilEnd')} $dayText';
      icon = HugeIconsStrokeRounded.clock01;
    } else {
      // Expira en más de 7 días
      warningColor = Colors.blue;
      message =
          '${SimpleLocalization.getText(ref, 'endsOn')} ${AppFormatters.formatDate(payment.endDate!, ref)}';
      icon = HugeIconsStrokeRounded.calendar01;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: warningColor, width: 1),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: warningColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: warningColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showModernActionMenu(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
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
                          SimpleLocalization.getText(ref, 'actions'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          SimpleLocalization.getText(
                            ref,
                            'manageYourRecurringPayment',
                          ),
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
                    icon: payment.isActive
                        ? HugeIconsStrokeRounded.pause
                        : HugeIconsStrokeRounded.play,
                    title: payment.isActive
                        ? SimpleLocalization.getText(ref, 'pause')
                        : SimpleLocalization.getText(ref, 'resume'),
                    subtitle: payment.isActive
                        ? SimpleLocalization.getText(ref, 'pauseSubtitle')
                        : SimpleLocalization.getText(ref, 'resumeSubtitle'),
                    color: payment.isActive ? Colors.orange : Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      onToggleStatus?.call();
                    },
                  ),

                  // Eliminar
                  _buildMenuOption(
                    context: context,
                    theme: theme,
                    icon: HugeIconsStrokeRounded.delete01,
                    title: SimpleLocalization.getText(ref, 'delete'),
                    subtitle: SimpleLocalization.getText(ref, 'deleteSubtitle'),
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

