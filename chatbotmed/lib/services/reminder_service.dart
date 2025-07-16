import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class ReminderService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: android),
    );
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String medicineName,
    required DateTime scheduledTime,
    bool isRepeating = false,
  }) async {
    final reminderTime = scheduledTime.subtract(const Duration(minutes: 5));
    final tzLocation = tz.local;
    await _notifications.zonedSchedule(
      id,
      'Waktunya Minum Obat',
      'Jangan lupa minum $medicineName',
      tz.TZDateTime.from(reminderTime, tzLocation),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminders',
          'Medication Reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
      ),
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // New parameter
      matchDateTimeComponents: isRepeating 
          ? DateTimeComponents.time 
          : null, // Optional repeating
    );
  }

  static Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}