import 'dart:async';
import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../models/recurring_payment.dart';
import 'notification_service.dart';
import '../services/hive_service.dart';

class TimerService {
  static final Map<String, Timer> _activeTimers = {};
  static final Map<String, DateTime> _scheduledTimes = {};

  /// Verifica si las notificaciones están habilitadas
  static bool _areNotificationsEnabled() {
    try {
      final appConfig = HiveService.getAppConfig();
      debugPrint(
        '🔔 Estado de notificaciones: ${appConfig.notificationsEnabled}',
      );
      return appConfig.notificationsEnabled;
    } catch (e) {
      debugPrint('⚠️ Error leyendo configuración de notificaciones: $e');
      return true; // Por defecto habilitadas si hay error
    }
  }

  /// Programa un recordatorio para una suscripción usando Timer
  static Future<void> scheduleSubscriptionReminder(
    Subscription subscription,
    DateTime reminderDate,
  ) async {
    // Verificar si las notificaciones están habilitadas
    if (!_areNotificationsEnabled()) {
      debugPrint(
        '🔕 Notificaciones deshabilitadas, no se programa el recordatorio',
      );
      return;
    }

    final subscriptionId = subscription.id;

    // Cancelar timer existente si existe
    _cancelExistingTimer(subscriptionId);

    final now = DateTime.now();
    final delay = reminderDate.difference(now);

    if (delay.isNegative) {
      debugPrint(
        '⚠️ La fecha ya pasó para ${subscription.name}, mostrando notificación inmediata',
      );
      // Verificar si las notificaciones están habilitadas antes de enviar
      if (!_areNotificationsEnabled()) {
        debugPrint(
          '🔕 Notificaciones deshabilitadas, cancelando recordatorio inmediato',
        );
        return;
      }
      await NotificationService.showSubscriptionReminder(
        subscriptionName: subscription.name,
        subscriptionId: subscription.id,
      );
      return;
    }

    debugPrint(
      '⏰ Programando recordatorio para ${subscription.name} en ${delay.inSeconds} segundos',
    );

    // Crear y guardar el timer
    final timer = Timer(delay, () async {
      // Verificar nuevamente antes de enviar
      if (!_areNotificationsEnabled()) {
        debugPrint('🔕 Notificaciones deshabilitadas, cancelando recordatorio');
        return;
      }

      debugPrint(
        '🔔 Ejecutando recordatorio programado para ${subscription.name}',
      );
      await NotificationService.showSubscriptionReminder(
        subscriptionName: subscription.name,
        subscriptionId: subscription.id,
      );

      // Limpiar el timer después de ejecutarse
      _activeTimers.remove(subscriptionId);
      _scheduledTimes.remove(subscriptionId);
    });

    _activeTimers[subscriptionId] = timer;
    _scheduledTimes[subscriptionId] = reminderDate;

    debugPrint(
      '✅ Recordatorio programado con Timer para: ${subscription.name}',
    );
  }

  /// Programa recordatorios para todas las suscripciones activas
  static Future<void> scheduleAllSubscriptionReminders(
    List<Subscription> subscriptions,
  ) async {
    // Verificar si las notificaciones están habilitadas antes de programar
    if (!_areNotificationsEnabled()) {
      debugPrint(
        '🔕 Notificaciones deshabilitadas, no se programan recordatorios',
      );
      return;
    }

    // Obtener la configuración de días de anticipación
    final appConfig = HiveService.getAppConfig();
    final reminderDays = appConfig.subscriptionReminderDays;

    debugPrint(
      '🔄 Programando recordatorios para ${subscriptions.length} suscripciones (${reminderDays} días de anticipación)',
    );

    for (final subscription in subscriptions) {
      if (subscription.isActive) {
        // Calcular la fecha de recordatorio restando los días de anticipación
        final reminderDate = subscription.nextPaymentDate.subtract(
          Duration(days: reminderDays),
        );

        await scheduleSubscriptionReminder(subscription, reminderDate);
      }
    }

    debugPrint('✅ Todos los recordatorios programados');
  }

  /// Cancela un recordatorio específico
  static void cancelSubscriptionReminder(String subscriptionId) {
    _cancelExistingTimer(subscriptionId);
    debugPrint('❌ Recordatorio cancelado para suscripción: $subscriptionId');
  }

  /// Cancela todos los recordatorios
  static void cancelAllReminders() {
    debugPrint('🔄 Cancelando todos los recordatorios...');

    for (final timer in _activeTimers.values) {
      timer.cancel();
    }

    _activeTimers.clear();
    _scheduledTimes.clear();

    debugPrint('✅ Todos los recordatorios cancelados');
  }

  /// Obtiene información de los timers activos
  static Map<String, DateTime> getActiveReminders() {
    return Map.from(_scheduledTimes);
  }

  /// Cancela un timer existente
  static void _cancelExistingTimer(String subscriptionId) {
    final existingTimer = _activeTimers[subscriptionId];
    if (existingTimer != null) {
      existingTimer.cancel();
      _activeTimers.remove(subscriptionId);
      _scheduledTimes.remove(subscriptionId);
      debugPrint('🔄 Timer existente cancelado para: $subscriptionId');
    }
  }

  /// Actualiza un recordatorio existente
  static Future<void> updateSubscriptionReminder(
    Subscription subscription,
    DateTime newReminderDate,
  ) async {
    debugPrint('🔄 Actualizando recordatorio para ${subscription.name}');

    // Obtener la configuración de días de anticipación
    final appConfig = HiveService.getAppConfig();
    final reminderDays = appConfig.subscriptionReminderDays;

    // Calcular la fecha de recordatorio restando los días de anticipación
    final reminderDate = subscription.nextPaymentDate.subtract(
      Duration(days: reminderDays),
    );

    await scheduleSubscriptionReminder(subscription, reminderDate);
  }

  // ========== MÉTODOS PARA PAGOS RECURRENTES ==========

  /// Programa un recordatorio para un pago recurrente (se ejecuta cuando se cumple la fecha)
  static Future<void> scheduleRecurringPaymentReminder(
    RecurringPayment payment,
    DateTime paymentDate, {
    Future<void> Function(RecurringPayment)? onPaymentDue,
  }) async {
    // Verificar si las notificaciones están habilitadas
    if (!_areNotificationsEnabled()) {
      debugPrint(
        '🔕 Notificaciones deshabilitadas, no se programa el recordatorio',
      );
      return;
    }

    final paymentId = payment.id;

    // Cancelar timer existente si existe
    _cancelExistingTimer('recurring_$paymentId');

    final now = DateTime.now();
    final delay = paymentDate.difference(now);

    if (delay.isNegative) {
      debugPrint(
        '⚠️ La fecha ya pasó para ${payment.name}, procesando pago inmediato',
      );
      // Si la fecha ya pasó, ejecutar callback inmediatamente
      if (onPaymentDue != null) {
        await onPaymentDue(payment);
      }
      return;
    }

    debugPrint(
      '⏰ Programando pago automático para ${payment.name} en ${delay.inSeconds} segundos',
    );

    // Crear y guardar el timer
    final timer = Timer(delay, () async {
      // Verificar nuevamente antes de procesar
      if (!_areNotificationsEnabled()) {
        debugPrint('🔕 Notificaciones deshabilitadas, cancelando pago automático');
        return;
      }

      debugPrint(
        '🔔 Ejecutando pago automático programado para ${payment.name}',
      );
      
      // Ejecutar callback para procesar el pago (crear transacción, etc.)
      if (onPaymentDue != null) {
        await onPaymentDue(payment);
      }

      // Limpiar el timer después de ejecutarse
      _activeTimers.remove('recurring_$paymentId');
      _scheduledTimes.remove('recurring_$paymentId');
    });

    _activeTimers['recurring_$paymentId'] = timer;
    _scheduledTimes['recurring_$paymentId'] = paymentDate;

    debugPrint(
      '✅ Pago automático programado con Timer para: ${payment.name}',
    );
  }

  /// Programa recordatorios para todos los pagos recurrentes activos
  static Future<void> scheduleAllRecurringPaymentReminders(
    List<RecurringPayment> payments, {
    Future<void> Function(RecurringPayment)? onPaymentDue,
  }) async {
    // Verificar si las notificaciones están habilitadas antes de programar
    if (!_areNotificationsEnabled()) {
      debugPrint(
        '🔕 Notificaciones deshabilitadas, no se programan pagos automáticos',
      );
      return;
    }

    debugPrint(
      '🔄 Programando pagos automáticos para ${payments.length} pagos recurrentes',
    );

    for (final payment in payments) {
      if (payment.isActive) {
        // Programar para la fecha de pago (no días antes, sino el día exacto)
        await scheduleRecurringPaymentReminder(
          payment,
          payment.nextPaymentDate,
          onPaymentDue: onPaymentDue,
        );
      }
    }

    debugPrint('✅ Todos los pagos automáticos programados');
  }

  /// Cancela un recordatorio específico de pago recurrente
  static void cancelRecurringPaymentReminder(String paymentId) {
    _cancelExistingTimer('recurring_$paymentId');
    debugPrint('❌ Pago automático cancelado para: $paymentId');
  }

  /// Cancela todos los recordatorios de pagos recurrentes
  static void cancelAllRecurringPaymentReminders() {
    debugPrint('🔄 Cancelando todos los pagos automáticos...');

    final keysToRemove = <String>[];
    for (final key in _activeTimers.keys) {
      if (key.startsWith('recurring_')) {
        _activeTimers[key]?.cancel();
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _activeTimers.remove(key);
      _scheduledTimes.remove(key);
    }

    debugPrint('✅ Todos los pagos automáticos cancelados');
  }
}
