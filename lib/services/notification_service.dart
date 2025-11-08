import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Ensure you have these dependencies in pubspec.yaml:
// flutter_local_notifications
// timezone
// flutter_native_timezone

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the plugin and sets up timezone data.
  Future<void> init() async {
    // Configure Timezone
    WidgetsFlutterBinding.ensureInitialized();
    await _configureLocalTimeZone();

    // Platform-specific settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // 3. Initialize plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification payload: ${details.payload}');
      },
    );

    // Request permissions explicitly (especially for Android 13+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Sets up the device's current timezone location.
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // Fixed to a common UTC+8 location ('Asia/Manila')
    const String timeZoneName = 'Asia/Manila';
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('Timezone fixed to: $timeZoneName (UTC+8)');
    } catch (e) {
      print("Could not set fixed timezone, defaulting to UTC: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Defines the notification channel details.
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'vaccination_channel_id',
        'Vaccination Reminders',
        channelDescription: 'Reminders for upcoming vaccinations.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Vaccine Reminder',
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleVaccinationReminder({
    required int id,
    required String childName,
    required String vaccinationName,
    required DateTime scheduleDate,
  }) async {
    final DateTime now = DateTime.now();

    // If the schedule date is today, trigger notification 30 seconds from now
    if (scheduleDate.year == now.year &&
        scheduleDate.month == now.month &&
        scheduleDate.day == now.day) {
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.now(
        tz.local,
      ).add(Duration(seconds: 5));

      await _notificationsPlugin.zonedSchedule(
        id,
        'Vaccination Due: ${vaccinationName}!',
        'It\'s time for ${childName}\'s $vaccinationName. Tap to view details.',
        scheduledTZDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: '$childName:$vaccinationName',
      );

      print(
        'Scheduled TEST reminder: $vaccinationName for child ID $id at $scheduledTZDate',
      );
      return;
    }

    // Otherwise schedule at 10:00 AM on the specified future date
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime(
      tz.local,
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      10,
      0,
    );

    if (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print(
        'Skipping $vaccinationName for $childName because time $scheduledTZDate is already past.',
      );
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      'Vaccination Due: ${vaccinationName}!',
      'It\'s time for ${childName}\'s $vaccinationName. Tap to view details.',
      scheduledTZDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: '$childName:$vaccinationName',
    );

    print('Scheduled $vaccinationName for child ID $id on $scheduledTZDate');
  }

  /// Cancels a specific scheduled notification by its unique ID.
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
