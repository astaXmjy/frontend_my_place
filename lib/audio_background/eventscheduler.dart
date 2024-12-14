import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
  print('cancell all notification');
}

Future<void> scheduleDailyNotificationsFromStorage() async {
  final now = DateTime.now();

  try {
    // Fetch saved events from local storage
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedEventsJson = prefs.getString("events");

    if (savedEventsJson != null) {
      final List<dynamic> savedEvents = jsonDecode(savedEventsJson);

      for (var i = 0; i < savedEvents.length; i++) {
        final event = savedEvents[i];

        // Parse hour, minute, and second from the start_time field
        final startTime = event['start_time'];
        if (startTime == null ||
            !RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(startTime)) {
          print('Invalid start_time for event: $event');
          continue;
        }

        final timeParts = startTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = int.parse(timeParts[2]);

        // Create DateTime for today
        var scheduleDate = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
          second,
        );

        // If the time has passed, schedule for the next day
        if (scheduleDate.isBefore(now)) {
          scheduleDate = scheduleDate.add(const Duration(days: 1));
        }

        if (event['name'].toLowerCase() == 'jumma') {
          while (scheduleDate.weekday != DateTime.friday) {
            scheduleDate = scheduleDate.add(Duration(days: 1));
          }
        }

        // Schedule the notification
        await flutterLocalNotificationsPlugin.zonedSchedule(
          i, // Unique ID for the notification
          'Event Reminder',
          'It\'s time for ${event['name']} at $startTime',
          tz.TZDateTime.from(scheduleDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_event_channel_id',
              'Daily Events',
              channelDescription: 'Notifications for daily scheduled events',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('azan1'),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        print('Notification scheduled for ${event['name']} at $startTime');
      }
    } else {
      print('No saved events found in local storage.');
    }
  } catch (e) {
    print('Error scheduling notifications from storage: $e');
  }
}

// Future<void> scheduleDailyNotifications(
//     List<Map<String, int>> eventTimes) async {
//   final now = DateTime.now();
//
//   for (var i = 0; i < eventTimes.length; i++) {
//     final event = eventTimes[i];
//
//     try {
//       // Extract hour, minute, second
//       final hour = event['hour'] ?? 0;
//       final minute = event['minute'] ?? 0;
//       final second = event['second'] ?? 0;
//
//       // Create DateTime for today
//       var scheduleDate = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         hour,
//         minute,
//         second,
//       );
//
//       // If the time has passed, schedule for the next day
//       if (scheduleDate.isBefore(now)) {
//         scheduleDate = scheduleDate.add(const Duration(days: 1));
//       }
//
//       // Schedule the notification
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         i, // Unique ID for the notification
//         'Event Reminder',
//         'It\'s time for your scheduled event at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}',
//         tz.TZDateTime.from(scheduleDate, tz.local),
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'daily_event_channel_id',
//             'Daily Events',
//             channelDescription: 'Notifications for daily scheduled events',
//             importance: Importance.high,
//             priority: Priority.high,
//             playSound: true,
//           ),
//         ),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );
//
//       print(
//           'Notification scheduled for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}');
//     } catch (e) {
//       print('Error scheduling notification for event: $event - $e');
//     }
//   }
// }
