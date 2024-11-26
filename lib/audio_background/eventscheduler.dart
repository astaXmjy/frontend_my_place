import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/audio_background/event.dart';
import 'package:frontend/audio_background/getevents.dart';
import 'package:frontend/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

Future<void> scheduleNotificationsFromSavedEvents(int placeId) async {
  try {
    final events = await getSavedEventsFromLocalStorage(placeId);

    if (events.isNotEmpty) {
      for (var event in events) {
        final startTimeParts = event.startTime.split(':');
        final now = DateTime.now();
        final scheduleDate = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(startTimeParts[0]),
          int.parse(startTimeParts[1]),
          int.parse(startTimeParts[2]),
        );

        if (scheduleDate.isAfter(now)) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            event.placeId,
            'Event Reminder',
            'It\'s time for ${event.name}',
            tz.TZDateTime.from(scheduleDate, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'event_channel_id',
                'Events',
                channelDescription: 'Notifications for scheduled events',
                importance: Importance.high,
                priority: Priority.high,
                playSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
      print('Notifications scheduled for ${events.length} events.');
    } else {
      print('No events found for notifications.');
    }
  } catch (e) {
    print('Error scheduling notifications: $e');
  }
}
