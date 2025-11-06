import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurring_payment.dart';
import '../models/transaction.dart';
import '../services/hive_service.dart';
import '../services/timer_service.dart';
import '../services/notification_service.dart';
import 'app_config_provider.dart';
import 'transaction_provider.dart';

/// Provider para todos los pagos recurrentes
final recurringPaymentsProvider =
    StateNotifierProvider<RecurringPaymentNotifier, List<RecurringPayment>>((
      ref,
    ) {
      return RecurringPaymentNotifier(ref);
    });

/// Provider para pagos recurrentes activos
final activeRecurringPaymentsProvider = Provider<List<RecurringPayment>>((ref) {
  final payments = ref.watch(recurringPaymentsProvider);
  return payments.where((payment) => payment.isActive).toList();
});

/// Provider para pagos recurrentes inactivos
final inactiveRecurringPaymentsProvider = Provider<List<RecurringPayment>>((
  ref,
) {
  final payments = ref.watch(recurringPaymentsProvider);
  return payments.where((payment) => !payment.isActive).toList();
});

/// Provider para pagos recurrentes por tipo
final recurringPaymentsByTypeProvider =
    Provider.family<List<RecurringPayment>, TransactionType>((ref, type) {
      final payments = ref.watch(activeRecurringPaymentsProvider);
      return payments.where((payment) => payment.type == type).toList();
    });

/// Provider para pagos recurrentes próximos a vencer
final dueSoonRecurringPaymentsProvider = Provider<List<RecurringPayment>>((
  ref,
) {
  final payments = ref.watch(activeRecurringPaymentsProvider);
  return payments.where((payment) => payment.isDueSoon).toList();
});

/// Provider para pagos recurrentes vencidos
final overdueRecurringPaymentsProvider = Provider<List<RecurringPayment>>((
  ref,
) {
  final payments = ref.watch(activeRecurringPaymentsProvider);
  return payments.where((payment) => payment.isOverdue).toList();
});

/// Provider para búsqueda de pagos recurrentes
final searchRecurringPaymentsProvider =
    Provider.family<List<RecurringPayment>, String>((ref, query) {
      final payments = ref.watch(recurringPaymentsProvider);
      if (query.isEmpty) return payments;

      final lowercaseQuery = query.toLowerCase();
      return payments.where((payment) {
        return payment.name.toLowerCase().contains(lowercaseQuery) ||
            (payment.description?.toLowerCase().contains(lowercaseQuery) ??
                false) ||
            (payment.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    });

/// Notifier para manejar los pagos recurrentes
class RecurringPaymentNotifier extends StateNotifier<List<RecurringPayment>> {
  final Ref _ref;

  RecurringPaymentNotifier(this._ref) : super([]) {
    _loadRecurringPayments();

    // Procesar pagos automáticos al inicializar
    Future.microtask(() => processAutomaticPayments());

    // Programar recordatorios para pagos recurrentes activos
    _initializeReminders();

    // Escuchar cambios en la configuración de la app para recargar pagos recurrentes
    _ref.listen(appConfigProvider, (previous, next) {
      if (previous?.currentAccountId != next.currentAccountId) {
        _loadRecurringPayments();
      }
    });

    // Asignar accountId a pagos recurrentes existentes que no lo tengan
    Future.microtask(() => assignAccountIdToExistingPayments());
  }

  /// Inicializa los recordatorios para todos los pagos recurrentes activos
  void _initializeReminders() {
    // Usar un Future.microtask para evitar problemas de inicialización
    Future.microtask(() async {
      await scheduleAllReminders();
    });
  }

  /// Carga todos los pagos recurrentes desde Hive (filtrados por cuenta actual)
  void _loadRecurringPayments() {
    final allPayments = HiveService.getAllRecurringPayments();
    final appConfig = _ref.read(appConfigProvider);
    final currentAccountId = appConfig.currentAccountId;

    // Si hay una cuenta actual, filtrar por ella
    if (currentAccountId != null) {
      state = allPayments.where((payment) {
        return payment.accountId == currentAccountId;
      }).toList();
    } else {
      state = allPayments;
    }

    // Verificar y pausar pagos recurrentes expirados automáticamente
    Future.microtask(() => _checkAndPauseExpiredPayments());
  }

  /// Verifica y pausa automáticamente los pagos recurrentes cuya fecha de fin ya pasó
  Future<void> _checkAndPauseExpiredPayments() async {
    final now = DateTime.now();
    final paymentsToUpdate = <RecurringPayment>[];

    for (final payment in state) {
      if (payment.isActive && payment.endDate != null) {
        final endDate = DateTime(
          payment.endDate!.year,
          payment.endDate!.month,
          payment.endDate!.day,
        );
        final today = DateTime(now.year, now.month, now.day);

        // Si la fecha de fin ya pasó, pausar el pago recurrente
        if (endDate.isBefore(today) || endDate.isAtSameMomentAs(today)) {
          final updatedPayment = payment.copyWith(isActive: false);
          paymentsToUpdate.add(updatedPayment);
        }
      }
    }

    // Actualizar todos los pagos recurrentes expirados
    for (final payment in paymentsToUpdate) {
      await HiveService.updateRecurringPayment(payment);
    }

    // Recargar los pagos recurrentes si hubo cambios
    if (paymentsToUpdate.isNotEmpty) {
      state = HiveService.getAllRecurringPayments();
    }
  }

  /// Agrega un nuevo pago recurrente
  Future<void> addRecurringPayment(RecurringPayment payment) async {
    // Asignar la cuenta actual si no tiene
    final appConfig = _ref.read(appConfigProvider);
    final paymentWithAccount = payment.copyWith(
      accountId: payment.accountId ?? appConfig.currentAccountId,
    );

    await HiveService.addRecurringPayment(paymentWithAccount);
    _loadRecurringPayments();

    // Programar recordatorio si está activo
    if (paymentWithAccount.isActive) {
      await scheduleReminder(paymentWithAccount);
    }
  }

  /// Actualiza un pago recurrente existente
  Future<void> updateRecurringPayment(RecurringPayment payment) async {
    await HiveService.updateRecurringPayment(payment);
    _loadRecurringPayments();
  }

  /// Elimina un pago recurrente
  Future<void> deleteRecurringPayment(String paymentId) async {
    // Cancelar recordatorio antes de eliminar
    cancelReminder(paymentId);

    await HiveService.deleteRecurringPayment(paymentId);
    _loadRecurringPayments();
  }

  /// Obtiene un pago recurrente por ID
  RecurringPayment? getRecurringPayment(String paymentId) {
    return HiveService.getRecurringPayment(paymentId);
  }

  /// Refresca la lista de pagos recurrentes
  void refresh() {
    _loadRecurringPayments();
  }

  /// Asigna accountId a pagos recurrentes existentes que no lo tengan
  Future<void> assignAccountIdToExistingPayments() async {
    final allPayments = HiveService.getAllRecurringPayments();
    final appConfig = _ref.read(appConfigProvider);
    final currentAccountId = appConfig.currentAccountId;

    if (currentAccountId == null) return;

    final paymentsToUpdate = <RecurringPayment>[];

    for (final payment in allPayments) {
      if (payment.accountId == null) {
        final updatedPayment = payment.copyWith(accountId: currentAccountId);
        paymentsToUpdate.add(updatedPayment);
      }
    }

    if (paymentsToUpdate.isNotEmpty) {
      for (final payment in paymentsToUpdate) {
        await HiveService.updateRecurringPayment(payment);
      }
      _loadRecurringPayments();
    }
  }

  /// Marca un pago recurrente como pagado (actualiza la próxima fecha de pago)
  Future<void> markAsPaid(String paymentId) async {
    final payment = getRecurringPayment(paymentId);
    if (payment != null) {
      final updatedPayment = payment.copyWith(
        nextPaymentDate: _calculateNextPayment(
          payment.nextPaymentDate,
          payment.frequency,
          payment.dayOfMonth,
        ),
      );
      await updateRecurringPayment(updatedPayment);
    }
  }

  /// Pausa/Reanuda un pago recurrente
  Future<void> togglePaymentStatus(String paymentId) async {
    final payment = getRecurringPayment(paymentId);
    if (payment != null) {
      final wasActive = payment.isActive;
      final updatedPayment = payment.copyWith(isActive: !payment.isActive);
      await updateRecurringPayment(updatedPayment);

      // Si se está pausando (desactivando), eliminar la transacción asociada
      if (wasActive && !updatedPayment.isActive) {
        await _deleteAssociatedTransaction(payment);
      }
    }
  }

  /// Elimina la transacción asociada a un pago recurrente
  Future<void> _deleteAssociatedTransaction(RecurringPayment payment) async {
    try {
      // Buscar transacciones que coincidan con el pago recurrente
      final allTransactions = _ref.read(transactionsProvider);

      // Buscar transacciones que coincidan con:
      // - Mismo título (nombre del pago)
      // - Mismo monto
      // - Misma categoría
      // - Mismo tipo
      // - Misma cuenta
      // - Fecha igual o cercana a la fecha de inicio
      final matchingTransactions = allTransactions.where((transaction) {
        final sameTitle = transaction.title == payment.name;
        final sameAmount = transaction.amount == payment.amount;
        final sameCategory = transaction.category == payment.category;
        final sameType = transaction.type == payment.type;
        final sameAccount = transaction.accountId == payment.accountId;

        // Verificar si la fecha es igual o muy cercana (mismo día)
        final transactionDate = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        final paymentDate = DateTime(
          payment.startDate.year,
          payment.startDate.month,
          payment.startDate.day,
        );
        final sameDate = transactionDate.isAtSameMomentAs(paymentDate);

        return sameTitle &&
            sameAmount &&
            sameCategory &&
            sameType &&
            sameAccount &&
            sameDate;
      }).toList();

      // Eliminar todas las transacciones que coincidan
      for (final transaction in matchingTransactions) {
        await _ref
            .read(transactionsProvider.notifier)
            .deleteTransaction(transaction.id);
      }
    } catch (e) {
      // Si hay un error, no hacer nada (no es crítico)
      debugPrint('Error al eliminar transacción asociada: $e');
    }
  }

  /// Procesa pagos automáticos para pagos recurrentes vencidos
  Future<void> processAutomaticPayments() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final payment in state) {
      // No procesar si el pago ya expiró (tiene endDate pasado)
      if (payment.endDate != null) {
        final endDate = DateTime(
          payment.endDate!.year,
          payment.endDate!.month,
          payment.endDate!.day,
        );
        if (endDate.isBefore(today) || endDate.isAtSameMomentAs(today)) {
          // Pausar si está activo
          if (payment.isActive) {
            await updateRecurringPayment(payment.copyWith(isActive: false));
          }
          continue; // No procesar pagos para pagos recurrentes expirados
        }
      }

      // Procesar pago automático solo para pagos activos no expirados
      if (payment.isActive) {
        final paymentDate = DateTime(
          payment.nextPaymentDate.year,
          payment.nextPaymentDate.month,
          payment.nextPaymentDate.day,
        );

        if (paymentDate.isBefore(today) ||
            paymentDate.isAtSameMomentAs(today)) {
          // Procesar pago automático
          await _processAutomaticPayment(payment);
        }
      }
    }
  }

  /// Procesa un pago automático individual
  Future<void> _processAutomaticPayment(RecurringPayment payment) async {
    // Crear transacción automática del pago
    await _createAutomaticTransaction(payment);

    // Calcular la nueva fecha de pago
    final newPaymentDate = _calculateNextPayment(
      payment.nextPaymentDate,
      payment.frequency,
      payment.dayOfMonth,
    );

    // Actualizar el pago recurrente con la nueva fecha
    final updatedPayment = payment.copyWith(nextPaymentDate: newPaymentDate);
    await updateRecurringPayment(updatedPayment);

    // Reprogramar la notificación para el próximo pago
    await scheduleReminder(updatedPayment);
  }

  /// Crea una transacción automática para el pago recurrente
  Future<void> _createAutomaticTransaction(RecurringPayment payment) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: payment.amount,
      title: payment.name,
      category: payment.category,
      type: payment.type,
      date: DateTime.now(), // Usar la fecha actual cuando se procesa
      notes: payment.notes,
      accountId: payment.accountId,
    );

    // Guardar la transacción usando el provider para que se actualice la UI
    await _ref.read(transactionsProvider.notifier).addTransaction(transaction);

    // Notificar que se procesó el pago
    await NotificationService.showRecurringPaymentProcessed(
      paymentName: payment.name,
      paymentAmount: payment.amount,
      paymentType: payment.type,
      paymentId: payment.id,
    );
  }

  /// Crea una transacción automática para el pago recurrente (método público para uso manual)
  Future<void> createTransactionFromPayment(RecurringPayment payment) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: payment.amount,
      title: payment.name,
      category: payment.category,
      type: payment.type,
      date: payment.startDate,
      notes: payment.notes,
      accountId: payment.accountId,
    );

    // Guardar la transacción usando el provider para que se actualice la UI
    await _ref.read(transactionsProvider.notifier).addTransaction(transaction);

    // Actualizar la próxima fecha de pago
    await markAsPaid(payment.id);
  }

  /// Programa recordatorios para todos los pagos recurrentes activos usando Timer
  Future<void> scheduleAllReminders() async {
    final activePayments = state.where((p) => p.isActive).toList();
    await TimerService.scheduleAllRecurringPaymentReminders(
      activePayments,
      onPaymentDue: _processAutomaticPayment,
    );
  }

  /// Programa un recordatorio específico usando Timer
  Future<void> scheduleReminder(RecurringPayment payment) async {
    await TimerService.scheduleRecurringPaymentReminder(
      payment,
      payment.nextPaymentDate,
      onPaymentDue: _processAutomaticPayment,
    );
  }

  /// Cancela un recordatorio específico
  void cancelReminder(String paymentId) {
    TimerService.cancelRecurringPaymentReminder(paymentId);
  }

  /// Cancela todos los recordatorios
  void cancelAllReminders() {
    TimerService.cancelAllRecurringPaymentReminders();
  }

  /// Calcula la próxima fecha de pago
  static DateTime _calculateNextPayment(
    DateTime startDate,
    RecurringFrequency frequency,
    int dayOfMonth,
  ) {
    final now = DateTime.now();
    DateTime nextPayment = startDate;

    while (nextPayment.isBefore(now) || nextPayment.isAtSameMomentAs(now)) {
      switch (frequency) {
        case RecurringFrequency.daily:
          nextPayment = nextPayment.add(const Duration(days: 1));
          break;
        case RecurringFrequency.weekly:
          nextPayment = nextPayment.add(const Duration(days: 7));
          break;
        case RecurringFrequency.monthly:
          if (dayOfMonth > 0) {
            nextPayment = DateTime(
              nextPayment.year,
              nextPayment.month + 1,
              dayOfMonth > 28 ? 28 : dayOfMonth,
            );
          } else {
            nextPayment = DateTime(
              nextPayment.year,
              nextPayment.month + 1,
              nextPayment.day,
            );
          }
          break;
        case RecurringFrequency.quarterly:
          if (dayOfMonth > 0) {
            nextPayment = DateTime(
              nextPayment.year,
              nextPayment.month + 3,
              dayOfMonth > 28 ? 28 : dayOfMonth,
            );
          } else {
            nextPayment = DateTime(
              nextPayment.year,
              nextPayment.month + 3,
              nextPayment.day,
            );
          }
          break;
        case RecurringFrequency.yearly:
          if (dayOfMonth > 0) {
            nextPayment = DateTime(
              nextPayment.year + 1,
              nextPayment.month,
              dayOfMonth > 28 ? 28 : dayOfMonth,
            );
          } else {
            nextPayment = DateTime(
              nextPayment.year + 1,
              nextPayment.month,
              nextPayment.day,
            );
          }
          break;
      }
    }

    return nextPayment;
  }
}
