import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../utils/app_formatters.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../widgets/add_subscription_sheet.dart';
import '../widgets/subscription_card.dart';
import '../widgets/search_input_field.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  SubscriptionFrequency? _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptions = ref.watch(subscriptionsProvider);
    final stats = ref.watch(subscriptionStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalization.getText(ref, 'subscriptions')),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIconsStrokeRounded.filter, size: 20),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: SimpleLocalization.getText(ref, 'all')),
            Tab(text: SimpleLocalization.getText(ref, 'active')),
            Tab(text: SimpleLocalization.getText(ref, 'inactive')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SearchInputField(
              controller: _searchController,
              hintText: SimpleLocalization.getText(ref, 'searchSubscriptions'),
              onChanged: () {
                setState(() {});
              },
              onClear: () {
                setState(() {});
              },
            ),
          ),

          // Estadísticas rápidas
          _buildStatsCards(theme, stats),

          // Lista de suscripciones
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubscriptionsList(subscriptions, 'Todas'),
                _buildSubscriptionsList(
                  subscriptions.where((s) => s.isActive).toList(),
                  'Activas',
                ),
                _buildSubscriptionsList(
                  subscriptions.where((s) => !s.isActive).toList(),
                  'Inactivas',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubscriptionDialog,
        icon: HugeIcon(icon: HugeIconsStrokeRounded.add01, size: 20),
        label: Text(SimpleLocalization.getText(ref, 'add')),
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme, SubscriptionStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              SimpleLocalization.getText(ref, 'monthlyCost'),
              AppFormatters.formatCurrency(stats.totalMonthlyCost, ref),
              HugeIconsStrokeRounded.calendar01,
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: _buildStatCard(
              theme,
              SimpleLocalization.getText(ref, 'yearlyCost'),
              AppFormatters.formatCurrency(stats.totalYearlyCost, ref),
              HugeIconsStrokeRounded.calendar01,
              theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: _buildStatCard(
              theme,
              SimpleLocalization.getText(ref, 'active'),
              '${stats.activeSubscriptions}',
              HugeIconsStrokeRounded.star,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    List<List<dynamic>> icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsList(
    List<Subscription> subscriptions,
    String type,
  ) {
    if (subscriptions.isEmpty) {
      return _buildEmptyState(type);
    }

    // Filtrar por búsqueda si hay texto
    final filteredSubscriptions = _searchController.text.isEmpty
        ? subscriptions
        : subscriptions.where((subscription) {
            final query = _searchController.text.toLowerCase();
            return subscription.name.toLowerCase().contains(query) ||
                subscription.description.toLowerCase().contains(query) ||
                (subscription.notes?.toLowerCase().contains(query) ?? false);
          }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: filteredSubscriptions.length,
      itemBuilder: (context, index) {
        final subscription = filteredSubscriptions[index];
        return SubscriptionCard(
          subscription: subscription,
          onTap: () => _showEditSubscriptionDialog(subscription),
          onToggleStatus: () => _toggleSubscriptionStatus(subscription),
          onMarkAsPaid: () => _markAsPaid(subscription),
          onDelete: () => _showDeleteDialog(subscription),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    final theme = Theme.of(context);
    String message;
    String subtitle;

    switch (type) {
      case 'Activas':
        message = SimpleLocalization.getText(ref, 'noActiveSubscriptions');
        subtitle = SimpleLocalization.getText(
          ref,
          'addFirstActiveSubscription',
        );
        break;
      case 'Inactivas':
        message = SimpleLocalization.getText(ref, 'noInactiveSubscriptions');
        subtitle = SimpleLocalization.getText(
          ref,
          'pausedSubscriptionsAppearHere',
        );
        break;
      default:
        message = SimpleLocalization.getText(ref, 'noSubscriptions');
        subtitle = SimpleLocalization.getText(ref, 'addFirstSubscription');
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIconsStrokeRounded.money01,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubscriptionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      builder: (context) => const AddSubscriptionSheet(),
    );
  }

  void _showEditSubscriptionDialog(Subscription subscription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      builder: (context) => AddSubscriptionSheet(subscription: subscription),
    );
  }

  void _toggleSubscriptionStatus(Subscription subscription) {
    ref
        .read(subscriptionsProvider.notifier)
        .toggleSubscriptionStatus(subscription.id);
  }

  void _markAsPaid(Subscription subscription) {
    ref.read(subscriptionsProvider.notifier).markAsPaid(subscription.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${subscription.name} ${SimpleLocalization.getText(ref, 'markedAsPaid')}',
        ),
        action: SnackBarAction(
          label: SimpleLocalization.getText(ref, 'undo'),
          onPressed: () {
            // TODO: Implementar deshacer
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'deleteSubscription')),
        content: Text(
          SimpleLocalization.getText(
            ref,
            'deleteSubscriptionConfirm',
          ).replaceAll('{name}', subscription.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(subscriptionsProvider.notifier)
                  .deleteSubscription(subscription.id);
              Navigator.pop(context);
            },
            child: Text(SimpleLocalization.getText(ref, 'delete')),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'filterSubscriptions')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<SubscriptionFrequency?>(
              value: _selectedFrequency,
              decoration: InputDecoration(
                labelText: SimpleLocalization.getText(ref, 'paymentFrequency'),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(SimpleLocalization.getText(ref, 'all')),
                ),
                DropdownMenuItem(
                  value: SubscriptionFrequency.daily,
                  child: Text(SimpleLocalization.getText(ref, 'daily')),
                ),
                DropdownMenuItem(
                  value: SubscriptionFrequency.weekly,
                  child: Text(SimpleLocalization.getText(ref, 'weekly')),
                ),
                DropdownMenuItem(
                  value: SubscriptionFrequency.monthly,
                  child: Text(SimpleLocalization.getText(ref, 'monthly')),
                ),
                DropdownMenuItem(
                  value: SubscriptionFrequency.quarterly,
                  child: Text(SimpleLocalization.getText(ref, 'quarterly')),
                ),
                DropdownMenuItem(
                  value: SubscriptionFrequency.yearly,
                  child: Text(SimpleLocalization.getText(ref, 'yearly')),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFrequency = null;
              });
              Navigator.pop(context);
            },
            child: Text(SimpleLocalization.getText(ref, 'clear')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'apply')),
          ),
        ],
      ),
    );
  }
}
