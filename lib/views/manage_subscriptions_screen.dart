import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../widgets/add_subscription_dialog.dart';
import '../widgets/icon_selector_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class ManageSubscriptionsScreen extends ConsumerWidget {
  const ManageSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalization.getText(ref, 'manageSubscriptions')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSubscriptionDialog(context, ref),
          ),
        ],
      ),
      body: subscriptions.isEmpty
          ? _buildEmptyState(context, ref, theme)
          : _buildSubscriptionsList(context, ref, subscriptions, theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubscriptionDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(SimpleLocalization.getText(ref, 'addSubscription')),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            SimpleLocalization.getText(ref, 'noSubscriptionsFound'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            SimpleLocalization.getText(ref, 'addFirstSubscription'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () => _showAddSubscriptionDialog(context, ref),
            icon: const Icon(Icons.add),
            label: Text(SimpleLocalization.getText(ref, 'addSubscription')),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList(
    BuildContext context,
    WidgetRef ref,
    List<Subscription> subscriptions,
    ThemeData theme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return _buildSubscriptionCard(context, ref, subscription, theme);
      },
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            int.parse(subscription.color.replaceFirst('#', '0xFF')),
          ),
          child: HugeIcon(
            icon: IconUtils.getIconFromString(subscription.icon),
            size: 20,
            color: Colors.white,
          ),
        ),
        title: Text(subscription.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subscription.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${subscription.amount.toStringAsFixed(2)}€',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  SimpleLocalization.getText(ref, subscription.frequency.name),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (subscription.isActive) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: subscription.isDueSoon
                        ? Colors.orange
                        : subscription.isOverdue
                        ? Colors.red
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Próximo pago: ${_formatDate(subscription.nextPaymentDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subscription.isDueSoon
                          ? Colors.orange
                          : subscription.isOverdue
                          ? Colors.red
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleSubscriptionAction(context, ref, value, subscription),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(SimpleLocalization.getText(ref, 'editSubscription')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(subscription.isActive ? Icons.pause : Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(subscription.isActive ? 'Pausar' : 'Activar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    SimpleLocalization.getText(ref, 'deleteSubscription'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubscriptionAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Subscription subscription,
  ) {
    switch (action) {
      case 'edit':
        _showEditSubscriptionDialog(context, ref, subscription);
        break;
      case 'toggle':
        _toggleSubscription(context, ref, subscription);
        break;
      case 'delete':
        _showDeleteSubscriptionDialog(context, ref, subscription);
        break;
    }
  }

  void _showAddSubscriptionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddSubscriptionDialog(
        onSubscriptionAdded: (subscription) {
          ref
              .read(subscriptionsProvider.notifier)
              .addSubscription(subscription);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                SimpleLocalization.getText(ref, 'subscriptionCreated'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditSubscriptionDialog(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddSubscriptionDialog(
        subscription: subscription,
        onSubscriptionAdded: (updatedSubscription) {
          ref
              .read(subscriptionsProvider.notifier)
              .updateSubscription(updatedSubscription);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                SimpleLocalization.getText(ref, 'subscriptionUpdated'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleSubscription(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) {
    final updatedSubscription = subscription.copyWith(
      isActive: !subscription.isActive,
    );
    ref
        .read(subscriptionsProvider.notifier)
        .updateSubscription(updatedSubscription);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedSubscription.isActive
              ? 'Suscripción activada'
              : 'Suscripción pausada',
        ),
      ),
    );
  }

  void _showDeleteSubscriptionDialog(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'deleteSubscription')),
        content: Text(
          SimpleLocalization.getText(ref, 'deleteSubscriptionConfirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(subscriptionsProvider.notifier)
                  .deleteSubscription(subscription.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    SimpleLocalization.getText(ref, 'subscriptionDeleted'),
                  ),
                ),
              );
            },
            child: Text(SimpleLocalization.getText(ref, 'delete')),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
