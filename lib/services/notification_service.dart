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
    // TEMPORARY TEST MODIFICATION:
    // If the schedule date is TODAY, we override the time to be 2 minutes from now.
    // This allows immediate testing of the notification scheduling system.
    // Otherwise, we schedule for 10:00 AM on the due date.
    final DateTime now = DateTime.now();

    int targetHour = 10;
    int targetMinute = 00;

    // Check if the scheduled date is today
    if (scheduleDate.year == now.year &&
        scheduleDate.month == now.month &&
        scheduleDate.day == now.day) {
      // Schedule 2 minutes into the future
      targetHour = now.hour;
      targetMinute = now.minute + 2;
    }

    // Use TZDateTime for accurate scheduling in the local timezone (fixed to UTC+8)
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime(
      tz.local,
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      targetHour,
      targetMinute,
    );

    // Check if the scheduled time is in the future
    if (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print(
        'Skipping $vaccinationName for $childName: calculated time $scheduledTZDate is in the past.',
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
