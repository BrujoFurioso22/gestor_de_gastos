import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import 'subscriptions_screen.dart';
import 'recurring_payments_screen.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(SimpleLocalization.getText(ref, 'services'))),
      body: ListView.separated(
        padding: EdgeInsets.only(
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
          top: AppConstants.defaultPadding,
          bottom:
              AppConstants.defaultPadding +
              MediaQuery.of(context).padding.bottom,
        ),
        itemCount: 2,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.colorScheme.outline.withOpacity(0.2),
          indent: 0,
          endIndent: 0,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildServiceListItem(
              context,
              theme,
              title: SimpleLocalization.getText(ref, 'subscriptions'),
              subtitle: SimpleLocalization.getText(ref, 'manageSubscriptions'),
              icon: HugeIconsStrokeRounded.money01,
              color: theme.colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionsScreen(),
                  ),
                );
              },
            );
          } else {
            return _buildServiceListItem(
              context,
              theme,
              title: SimpleLocalization.getText(ref, 'recurringPayments'),
              subtitle: SimpleLocalization.getText(
                ref,
                'recurringPaymentsDescription',
              ),
              icon: HugeIconsStrokeRounded.arrowUpDown,
              color: theme.colorScheme.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecurringPaymentsScreen(),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildServiceListItem(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String subtitle,
    required List<List<dynamic>> icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      color: theme.colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: HugeIcon(icon: icon, size: 24, color: color),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: HugeIcon(icon: HugeIconsStrokeRounded.arrowRight01, size: 20),
        onTap: onTap,
      ),
    );
  }
}
