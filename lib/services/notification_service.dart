import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'simple_localization.dart';
import '../services/hive_service.dart';
import '../models/transaction.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Obtiene el texto traducido según el idioma configurado
  static String _getTranslatedText(String key) {
    try {
      final appConfig = HiveService.getAppConfig();
      final isEnglish = appConfig.language == 'en';
      return SimpleLocalization.getTextByKey(key, isEnglish);
    } catch (e) {
      // Si hay error, devolver la clave
      return key;
    }
  }

  /// Inicializa el servicio de notificaciones
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notificación tocada: ${response.payload}');
      },
    );
  }

  /// Solicita permisos de notificación
  static Future<bool> requestPermissions() async {
    final notificationStatus = await Permission.notification.request();
    final alarmStatus = await Permission.scheduleExactAlarm.request();

    return notificationStatus.isGranted && alarmStatus.isGranted;
  }

  /// Muestra una notificación inmediata
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'immediate_notifications',
          _getTranslatedText('immediateNotifications'),
          channelDescription: _getTranslatedText(
            'immediateNotificationsDescription',
          ),
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Muestra una notificación de recordatorio de suscripción
  static Future<void> showSubscriptionReminder({
    required String subscriptionName,
    required String subscriptionId,
  }) async {
    await showImmediateNotification(
      title: _getTranslatedText('paymentReminder'),
      body: '$subscriptionName ${_getTranslatedText('subscriptionDueSoon')}',
      payload: 'subscription_$subscriptionId',
    );
  }

  /// Muestra una notificación cuando se procesa un pago recurrente automáticamente
  static Future<void> showRecurringPaymentProcessed({
    required String paymentName,
    required double paymentAmount,
    required TransactionType paymentType,
    required String paymentId,
  }) async {
    final typeText = paymentType == TransactionType.income
        ? _getTranslatedText('incomeType')
        : _getTranslatedText('expenseType');

    final amountText = _formatCurrency(paymentAmount);

    await showImmediateNotification(
      title: _getTranslatedText('paymentProcessed'),
      body: '$typeText: $paymentName - $amountText',
      payload: 'recurring_payment_$paymentId',
    );
  }

  /// Formatea el monto como moneda
  static String _formatCurrency(double amount) {
    final appConfig = HiveService.getAppConfig();
    final currency = appConfig.currency;

    switch (currency) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'MXN':
        return '\$${amount.toStringAsFixed(2)}';
      case 'GBP':
        return '£${amount.toStringAsFixed(2)}';
      case 'CAD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'AUD':
        return '\$${amount.toStringAsFixed(2)}';
      default:
        return '€${amount.toStringAsFixed(2)}';
    }
  }

  /// Obtiene el estado de los permisos
  static Future<bool> areNotificationsEnabled() async {
    return await Permission.notification.isGranted;
  }

  /// Abre la configuración de notificaciones del sistema
  static Future<void> openNotificationSettings() async {
    await openAppSettings();
  }
}
