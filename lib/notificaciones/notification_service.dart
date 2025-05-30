import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart'
    as tz; // Necesitarás el paquete timezone

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService(this.flutterLocalNotificationsPlugin);

  Future<void> scheduleSavingReminder() async {
    const AndroidNotificationDetails
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'saving_reminders', // ID del canal
      'Recordatorios de Ahorro', // Nombre del canal
      channelDescription:
          'Recordatorios para registrar tus ahorros', // Descripción del canal
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Obtener la zona horaria local
    final tz.Location local = tz.local;

    // Programar la notificación para dentro de 7 días a la misma hora
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID único de la notificación (cambia para notificaciones diferentes)
      '¡No olvides tus ahorros!',
      'Es un buen momento para registrar tu progreso hacia tus metas.',
      tz.TZDateTime.now(
        local,
      ).add(const Duration(days: 7)), // Programar para dentro de 7 días
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Para recordatorios recurrentes (ej. cada lunes a una hora)
      payload:
          'saving_goal_reminder', // Un payload para identificar la notificación al tocarla
    );
    print('Recordatorio de ahorro programado para dentro de 7 días.');
  }

  // Puedes añadir más funciones para programar diferentes tipos de notificaciones aquí
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'instant_notifications',
          'Notificaciones Instantáneas',
          channelDescription: 'Notificaciones que aparecen inmediatamente',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
    print('Notificación instantánea mostrada: $title');
  }
}
