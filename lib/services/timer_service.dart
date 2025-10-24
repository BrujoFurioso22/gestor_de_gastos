import 'dart:async';
import 'package:flutter/material.dart';
import '../models/subscription.dart';
import 'notification_service.dart';

class TimerService {
  static final Map<String, Timer> _activeTimers = {};
  static final Map<String, DateTime> _scheduledTimes = {};

  /// Programa un recordatorio para una suscripción usando Timer
  static Future<void> scheduleSubscriptionReminder(
    Subscription subscription,
    DateTime reminderDate,
  ) async {
    final subscriptionId = subscription.id;

    // Cancelar timer existente si existe
    _cancelExistingTimer(subscriptionId);

    final now = DateTime.now();
    final delay = reminderDate.difference(now);

    if (delay.isNegative) {
      debugPrint(
        '⚠️ La fecha ya pasó para ${subscription.name}, mostrando notificación inmediata',
      );
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
    debugPrint(
      '🔄 Programando recordatorios para ${subscriptions.length} suscripciones',
    );

    for (final subscription in subscriptions) {
      if (subscription.isActive) {
        await scheduleSubscriptionReminder(
          subscription,
          subscription.nextPaymentDate,
        );
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
    await scheduleSubscriptionReminder(subscription, newReminderDate);
  }
}
