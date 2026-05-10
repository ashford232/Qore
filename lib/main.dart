import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/app/config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;

Future<void> requestAppPermissions() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      await [
        Permission.notification,
        Permission.photos,
        Permission.videos,
        Permission.audio,
        Permission.scheduleExactAlarm,
      ].request();
    } else {
      await [Permission.storage, Permission.notification].request();
    }
  }
}

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(android: androidInit);

  await notificationsPlugin.initialize(settings: initSettings);
}

Future<void> scheduleDailyReminder() async {
  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    12,
    0,
    0,
  );
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  debugPrint("Current Time: $now");
  debugPrint("Scheduled Date: $scheduledDate");

  await notificationsPlugin.zonedSchedule(
    id: 0,
    title: 'Qore',
    body: 'Don’t forget to add your notes today 🚀',
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
    scheduledDate: scheduledDate,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel',
        'Daily Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await requestAppPermissions();
  await initNotifications();
  await scheduleDailyReminder();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qore',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),

        appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),

        appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
      ),

      themeMode: ThemeMode.system,
      home: Config(),
    );
  }
}
