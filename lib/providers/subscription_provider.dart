import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../models/transaction.dart';
import '../services/hive_service.dart';
import '../services/timer_service.dart';
import 'transaction_provider.dart';

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
    // Procesar pagos automáticos al inicializar
    processAutomaticPayments();
    // Programar recordatorios para suscripciones activas
    _initializeReminders();
  }

  /// Inicializa los recordatorios para todas las suscripciones activas
  void _initializeReminders() {
    // Usar un Future.microtask para evitar problemas de inicialización
    Future.microtask(() async {
      await scheduleAllReminders();
    });
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

    // Programar recordatorio si está activa
    if (subscription.isActive) {
      await scheduleReminder(subscription);
    }
  }

  /// Actualiza una suscripción existente
  Future<void> updateSubscription(Subscription subscription) async {
    print('🔄 Actualizando suscripción: ${subscription.name}');
    await HiveService.updateSubscription(subscription);
    print('✅ Suscripción actualizada en Hive');
    _loadSubscriptions();

    // Actualizar recordatorio
    if (subscription.isActive) {
      await scheduleReminder(subscription);
    } else {
      cancelReminder(subscription.id);
    }
  }

  /// Elimina una suscripción
  Future<void> deleteSubscription(String subscriptionId) async {
    print('🔄 Eliminando suscripción: $subscriptionId');

    // Cancelar recordatorio antes de eliminar
    cancelReminder(subscriptionId);

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

  /// Procesa pagos automáticos para suscripciones vencidas
  Future<void> processAutomaticPayments() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final subscription in state) {
      if (subscription.isActive &&
              subscription.nextPaymentDate.isBefore(today) ||
          subscription.nextPaymentDate.isAtSameMomentAs(today)) {
        // Procesar pago automático
        await _processAutomaticPayment(subscription);
      }
    }
  }

  /// Programa recordatorios para todas las suscripciones activas usando Timer
  Future<void> scheduleAllReminders() async {
    final activeSubscriptions = state.where((s) => s.isActive).toList();
    await TimerService.scheduleAllSubscriptionReminders(activeSubscriptions);
  }

  /// Programa un recordatorio específico usando Timer
  Future<void> scheduleReminder(Subscription subscription) async {
    await TimerService.scheduleSubscriptionReminder(
      subscription,
      subscription.nextPaymentDate,
    );
  }

  /// Cancela un recordatorio específico
  void cancelReminder(String subscriptionId) {
    TimerService.cancelSubscriptionReminder(subscriptionId);
  }

  /// Cancela todos los recordatorios
  void cancelAllReminders() {
    TimerService.cancelAllReminders();
  }

  /// Procesa pagos automáticos para suscripciones vencidas (método público)
  Future<void> processOverduePayments() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final subscription in state) {
      if (subscription.isActive &&
          (subscription.nextPaymentDate.isBefore(today) ||
              subscription.nextPaymentDate.isAtSameMomentAs(today))) {
        await _processAutomaticPayment(subscription);
      }
    }
  }

  /// Procesa un pago automático individual
  Future<void> _processAutomaticPayment(Subscription subscription) async {
    // Calcular la nueva fecha de pago
    final newPaymentDate = _calculateNextPayment(
      subscription.nextPaymentDate,
      subscription.frequency,
    );

    // Actualizar la suscripción con la nueva fecha
    final updatedSubscription = subscription.copyWith(
      nextPaymentDate: newPaymentDate,
    );
    await updateSubscription(updatedSubscription);

    // Crear transacción automática del pago
    await _createAutomaticTransaction(subscription);

    // Reprogramar la notificación para el próximo pago
    await scheduleReminder(updatedSubscription);

    print('💰 Pago automático procesado para: ${subscription.name}');
    print('📅 Nueva fecha de pago: $newPaymentDate');
    print('⏰ Recordatorio reprogramado para el próximo pago');
  }

  /// Crea una transacción automática para el pago de suscripción
  Future<void> _createAutomaticTransaction(Subscription subscription) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: subscription.amount,
      description: 'Pago automático - ${subscription.name}',
      category: 'expense_subscriptions',
      type: TransactionType.expense,
      date: DateTime.now(),
      icon: subscription.icon,
      color: subscription.color,
    );

    // Guardar la transacción en Hive
    await HiveService.addTransaction(transaction);

    print('💳 Transacción automática creada: ${transaction.description}');
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
