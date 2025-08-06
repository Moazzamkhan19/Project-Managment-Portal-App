import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
class NotificationService
{
  static void init()
  {
    AwesomeNotifications().initialize(null, [
      NotificationChannel(channelKey: 'task_channel', channelName: 'Task Notification',
          channelDescription:'Notification for task deadline',defaultColor: const Color(0xFF9D50DD),importance: NotificationImportance.High, )

    ],
    debug: true,
    );
  }
  static Future<void> showDueDateNotification(String title, String body, int id) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'task_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
  static Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
      print('Notification with ID $id canceled successfully.');
    } catch (e) {
      print('Error cancelling notification with ID $id: $e');
    }
  }
  static Future<void> schedulePriorityNotification({
    required String title,
    required String body,
    required int id,
    required Duration delay,
  }) async {
    final scheduleTime = DateTime.now().add(delay);

    final localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'task_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: scheduleTime.year,
        month: scheduleTime.month,
        day: scheduleTime.day,
        hour: scheduleTime.hour,
        minute: scheduleTime.minute,
        second: scheduleTime.second,
        millisecond: 0, // Important: Flutter has a bug with exact millisecond mismatch
        timeZone: localTimeZone,
        preciseAlarm: true,
        repeats: false,
      ),
    );
  }



}