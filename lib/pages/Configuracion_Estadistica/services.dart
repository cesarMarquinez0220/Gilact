import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('icono_basico');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


Future<void> notificacionPrueba() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  DateTime lastOpened = DateTime.parse(prefs.getString('last_opened') ?? '');
  DateTime now = DateTime.now();
  Duration difference = now.difference(lastOpened);

  if (difference.inMinutes >= 2) {
    List<String> messages = [
      'No te olvides de ver las lecciones! Hay mucho por aprender',
      'Refuerza tu conocimiento, Tu bebe lo agradecera!'
    ];

    int index = now.day % messages.length; // alternar entre los dos mensajes
    String message = messages[index];

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.high, priority: Priority.max);

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, '', message, notificationDetails);

    // Guardar la fecha y hora actual como la última apertura de la aplicación
    prefs.setString('last_opened', now.toString());
  }
}
