import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../services/hive_service.dart';

/// Provider para todas las suscripciones
final subscriptionsProvider =
    StateNotifierProvider<SubscriptionNotifier, List<Subscription>>((ref) {
      return SubscriptionNotifier();
    });

/// Provider para suscripciones activas
final activeSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider);
  return subscriptions.where((subscription) => subscription.isActive).toList();
});

/// Provider para suscripciones inactivas
final inactiveSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider);
  return subscriptions.where((subscription) => !subscription.isActive).toList();
});

/// Provider para suscripciones próximas a vencer
final dueSoonSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final subscriptions = ref.watch(activeSubscriptionsProvider);
  return subscriptions.where((subscription) => subscription.isDueSoon).toList();
});

/// Provider para suscripciones vencidas
final overdueSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final subscriptions = ref.watch(activeSubscriptionsProvider);
  return subscriptions.where((subscription) => subscription.isOverdue).toList();
});

/// Provider para estadísticas de suscripciones
final subscriptionStatsProvider = Provider<SubscriptionStats>((ref) {
  final subscriptions = ref.watch(activeSubscriptionsProvider);
  return _calculateStats(subscriptions);
});

/// Provider para suscripciones por frecuencia
final subscriptionsByFrequencyProvider =
    Provider.family<List<Subscription>, SubscriptionFrequency>((
      ref,
      frequency,
    ) {
      final subscriptions = ref.watch(activeSubscriptionsProvider);
      return subscriptions
          .where((subscription) => subscription.frequency == frequency)
          .toList();
    });

/// Provider para búsqueda de suscripciones
final searchSubscriptionsProvider = Provider.family<List<Subscription>, String>(
  (ref, query) {
    final subscriptions = ref.watch(subscriptionsProvider);
    if (query.isEmpty) return subscriptions;

    final lowercaseQuery = query.toLowerCase();
    return subscriptions.where((subscription) {
      return subscription.name.toLowerCase().contains(lowercaseQuery) ||
          subscription.description.toLowerCase().contains(lowercaseQuery) ||
          (subscription.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  },
);

/// Notifier para manejar las suscripciones
class SubscriptionNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionNotifier() : super([]) {
    _loadSubscriptions();
  }

  /// Carga todas las suscripciones desde Hive
  void _loadSubscriptions() {
    state = HiveService.getAllSubscriptions();
  }

  /// Agrega una nueva suscripción
  Future<void> addSubscription(Subscription subscription) async {
    print('🔄 Agregando suscripción: ${subscription.name}');
    await HiveService.addSubscription(subscription);
    print('✅ Suscripción guardada en Hive');
    _loadSubscriptions();
    print('📊 Suscripciones cargadas: ${state.length}');
  }

  /// Actualiza una suscripción existente
  Future<void> updateSubscription(Subscription subscription) async {
    print('🔄 Actualizando suscripción: ${subscription.name}');
    await HiveService.updateSubscription(subscription);
    print('✅ Suscripción actualizada en Hive');
    _loadSubscriptions();
  }

  /// Elimina una suscripción
  Future<void> deleteSubscription(String subscriptionId) async {
    print('🔄 Eliminando suscripción: $subscriptionId');
    await HiveService.deleteSubscription(subscriptionId);
    print('✅ Suscripción eliminada de Hive');
    _loadSubscriptions();
  }

  /// Obtiene una suscripción por ID
  Subscription? getSubscription(String subscriptionId) {
    return HiveService.getSubscription(subscriptionId);
  }

  /// Refresca la lista de suscripciones
  void refresh() {
    _loadSubscriptions();
  }

  /// Marca una suscripción como pagada (actualiza la próxima fecha de pago)
  Future<void> markAsPaid(String subscriptionId) async {
    final subscription = getSubscription(subscriptionId);
    if (subscription != null) {
      final updatedSubscription = subscription.copyWith(
        nextPaymentDate: _calculateNextPayment(
          subscription.nextPaymentDate,
          subscription.frequency,
        ),
      );
      await updateSubscription(updatedSubscription);
    }
  }

  /// Pausa/Reanuda una suscripción
  Future<void> toggleSubscriptionStatus(String subscriptionId) async {
    final subscription = getSubscription(subscriptionId);
    if (subscription != null) {
      final updatedSubscription = subscription.copyWith(
        isActive: !subscription.isActive,
      );
      await updateSubscription(updatedSubscription);
    }
  }

  /// Obtiene suscripciones por frecuencia
  List<Subscription> getSubscriptionsByFrequency(
    SubscriptionFrequency frequency,
  ) {
    return state
        .where((subscription) => subscription.frequency == frequency)
        .toList();
  }

  /// Busca suscripciones por texto
  List<Subscription> searchSubscriptions(String query) {
    if (query.isEmpty) return state;

    final lowercaseQuery = query.toLowerCase();
    return state.where((subscription) {
      return subscription.name.toLowerCase().contains(lowercaseQuery) ||
          subscription.description.toLowerCase().contains(lowercaseQuery) ||
          (subscription.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Calcula la próxima fecha de pago
  static DateTime _calculateNextPayment(
    DateTime startDate,
    SubscriptionFrequency frequency,
  ) {
    final now = DateTime.now();
    DateTime nextPayment = startDate;

    while (nextPayment.isBefore(now) || nextPayment.isAtSameMomentAs(now)) {
      switch (frequency) {
        case SubscriptionFrequency.daily:
          nextPayment = nextPayment.add(const Duration(days: 1));
          break;
        case SubscriptionFrequency.weekly:
          nextPayment = nextPayment.add(const Duration(days: 7));
          break;
        case SubscriptionFrequency.monthly:
          nextPayment = DateTime(
            nextPayment.year,
            nextPayment.month + 1,
            nextPayment.day,
          );
          break;
        case SubscriptionFrequency.quarterly:
          nextPayment = DateTime(
            nextPayment.year,
            nextPayment.month + 3,
            nextPayment.day,
          );
          break;
        case SubscriptionFrequency.yearly:
          nextPayment = DateTime(
            nextPayment.year + 1,
            nextPayment.month,
            nextPayment.day,
          );
          break;
      }
    }

    return nextPayment;
  }
}

/// Estadísticas de suscripciones
class SubscriptionStats {
  final double totalMonthlyCost;
  final double totalYearlyCost;
  final int activeSubscriptions;
  final int inactiveSubscriptions;
  final int dueSoonCount;
  final int overdueCount;
  final Map<SubscriptionFrequency, double> costByFrequency;

  const SubscriptionStats({
    required this.totalMonthlyCost,
    required this.totalYearlyCost,
    required this.activeSubscriptions,
    required this.inactiveSubscriptions,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.costByFrequency,
  });
}

/// Calcula estadísticas de las suscripciones
SubscriptionStats _calculateStats(List<Subscription> subscriptions) {
  double totalMonthlyCost = 0;
  double totalYearlyCost = 0;
  int dueSoonCount = 0;
  int overdueCount = 0;
  final Map<SubscriptionFrequency, double> costByFrequency = {};

  for (final subscription in subscriptions) {
    if (subscription.isActive) {
      totalMonthlyCost += subscription.monthlyCost;
      totalYearlyCost += subscription.yearlyCost;

      costByFrequency[subscription.frequency] =
          (costByFrequency[subscription.frequency] ?? 0) +
          subscription.monthlyCost;

      if (subscription.isDueSoon) dueSoonCount++;
      if (subscription.isOverdue) overdueCount++;
    }
  }

  return SubscriptionStats(
    totalMonthlyCost: totalMonthlyCost,
    totalYearlyCost: totalYearlyCost,
    activeSubscriptions: subscriptions.where((s) => s.isActive).length,
    inactiveSubscriptions: subscriptions.where((s) => !s.isActive).length,
    dueSoonCount: dueSoonCount,
    overdueCount: overdueCount,
    costByFrequency: costByFrequency,
  );
}
