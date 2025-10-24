import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

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

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'immediate_notifications',
          'Notificaciones Inmediatas',
          channelDescription: 'Notificaciones que se muestran inmediatamente',
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

    const NotificationDetails details = NotificationDetails(
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
      title: 'Recordatorio de Pago',
      body: '$subscriptionName vence hoy. ¡No olvides pagarlo!',
      payload: 'subscription_$subscriptionId',
    );
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
