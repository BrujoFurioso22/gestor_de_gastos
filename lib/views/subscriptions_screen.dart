import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../utils/app_formatters.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../widgets/forms/subscription_form.dart';
import '../widgets/cards/subscription_card.dart';
import '../widgets/inputs/search_input_field.dart';
import '../widgets/inputs/custom_floating_action_button.dart';

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
                _buildSubscriptionsList(subscriptions, 'all'),
                _buildSubscriptionsList(
                  subscriptions.where((s) => s.isActive).toList(),
                  'active',
                ),
                _buildSubscriptionsList(
                  subscriptions.where((s) => !s.isActive).toList(),
                  'inactive',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: _showAddSubscriptionDialog,
        // label: SimpleLocalization.getText(ref, 'add'), // Descomenta si quieres label
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme, SubscriptionStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants
            .defaultPadding, // Reducido de AppConstants.smallPadding a 4
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              SimpleLocalization.getText(ref, 'monthlyCost'),
              AppFormatters.formatCurrency(stats.totalMonthlyCost, ref),
              null, // Ya no necesitamos el icono
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _buildStatCard(
              theme,
              SimpleLocalization.getText(ref, 'yearlyCost'),
              AppFormatters.formatCurrency(stats.totalYearlyCost, ref),
              null, // Ya no necesitamos el icono
              theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _buildStatCard(
              theme,
              SimpleLocalization.getText(ref, 'active'),
              '${stats.activeSubscriptions}',
              null, // Ya no necesitamos el icono
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
    List<List<dynamic>>? icon, // Hacer el icono opcional
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6), // Reducido aún más de 8 a 6
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14, // Aumentado ligeramente ya que no hay icono
              ),
            ),
            const SizedBox(height: 2), // Espaciado mínimo
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
      padding: EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        bottom: AppConstants.defaultPadding +
            MediaQuery.of(context).padding.bottom,
      ),
      itemCount: filteredSubscriptions.length,
      itemBuilder: (context, index) {
        final subscription = filteredSubscriptions[index];
        return SubscriptionCard(
          subscription: subscription,
          onTap: () => _showEditSubscriptionDialog(subscription),
          onToggleStatus: () => _toggleSubscriptionStatus(subscription),
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
      case 'active':
        message = SimpleLocalization.getText(ref, 'noActiveSubscriptions');
        subtitle = SimpleLocalization.getText(
          ref,
          'addFirstActiveSubscription',
        );
        break;
      case 'inactive':
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
      builder: (context) => const SubscriptionForm(isEdit: false),
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
      builder: (context) =>
          SubscriptionForm(subscription: subscription, isEdit: true),
    );
  }

  void _toggleSubscriptionStatus(Subscription subscription) {
    ref
        .read(subscriptionsProvider.notifier)
        .toggleSubscriptionStatus(subscription.id);
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
}
