```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      notifications =
      FlutterLocalNotificationsPlugin();

  // =========================================================
  // INITIALIZE
  // =========================================================

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezoneInfo =
        await FlutterTimezone.getLocalTimezone();

    String timezoneName =
        timezoneInfo.identifier;

    // Convert old Android timezone name
    // to the timezone name used by timezone package.
    if (timezoneName == 'Asia/Calcutta') {
      timezoneName = 'Asia/Kolkata';
    }

    tz.setLocalLocation(
      tz.getLocation(timezoneName),
    );

    const AndroidInitializationSettings
        androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings: settings,
    );
  }

  // =========================================================
  // REQUEST NOTIFICATION PERMISSION
  // =========================================================

  static Future<void> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin?
        android =
        notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
  }

  // =========================================================
  // INSTANT NOTIFICATION
  // =========================================================

  static Future<void> showMedicineReminder(
    String medicineName,
  ) async {
    const AndroidNotificationDetails
        androidDetails =
        AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription:
          'Reminders for medicines',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      id: 1,
      title: '💊 Medicine Reminder',
      body: 'Time to take $medicineName',
      notificationDetails: details,
    );
  }

  // =========================================================
  // TEST SCHEDULED NOTIFICATION
  // =========================================================

  static Future<void>
      scheduleTestNotification() async {
    final now =
        tz.TZDateTime.now(tz.local);

    final scheduledDate =
        now.add(
      const Duration(minutes: 2),
    );

    const AndroidNotificationDetails
        androidDetails =
        AndroidNotificationDetails(
      'medicine_test',
      'Medicine Test',
      channelDescription:
          'Test scheduled medicine notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.zonedSchedule(
      id: 9999,
      title: '⏰ Scheduled Test',
      body:
          'Scheduled notification is working!',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle,
    );
  }

  // =========================================================
  // DAILY MEDICINE REMINDER
  // =========================================================

  static Future<void>
      scheduleDailyReminder({
    required int notificationId,
    required String medicineName,
    required int hour,
    required int minute,
  }) async {
    final now =
        tz.TZDateTime.now(tz.local);

    var scheduledDate =
        tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's time has already passed,
    // schedule it for tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate =
          scheduledDate.add(
        const Duration(days: 1),
      );
    }

    const AndroidNotificationDetails
        androidDetails =
        AndroidNotificationDetails(
      'medicine_daily_reminders',
      'Daily Medicine Reminders',
      channelDescription:
          'Daily reminders to take medicines',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.zonedSchedule(
      id: notificationId,
      title: '💊 Medicine Reminder',
      body:
          'Time to take $medicineName',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time,
    );
  }

  // =========================================================
  // CANCEL REMINDER
  // =========================================================

  static Future<void> cancelReminder(
    int notificationId,
  ) async {
    await notifications.cancel(
      id: notificationId,
    );
  }
}
```

