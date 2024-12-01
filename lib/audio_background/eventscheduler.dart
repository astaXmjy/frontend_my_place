import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/audio_background/event.dart';
import 'package:frontend/audio_background/getevents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> scheduleNotificationsFromSavedEvents(int placeId) async {
  try {
    final events = await getSavedEventsFromLocalStorage(placeId);

    if (events.isNotEmpty) {
      for (var event in events) {
        // Validate placeId and startTime
        if (event.placeId == null || event.startTime == null) {
          print('Skipping event with missing data: ${event.toJson()}');
          continue;
        }

        try {
          final startTimeParts = event.startTime.split(':');
          if (startTimeParts.length != 3) {
            print('Invalid startTime format: ${event.startTime}');
            continue;
          }

          final now = DateTime.now();
          final scheduleDate = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]),
            int.parse(startTimeParts[2]),
          );

          if (event.name.toLowerCase() == 'jumma') {
            // Schedule weekly notification for Fridays
            await _scheduleWeeklyNotification(scheduleDate, event);
          } else {
            // Schedule daily notification
            await _scheduleDailyNotification(scheduleDate, event);
          }
        } catch (e) {
          print('Error processing event: ${event.toJson()} - Error: $e');
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

Future<void> _scheduleDailyNotification(
    DateTime scheduleDate, Event event) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    event.placeId!,
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
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<void> _scheduleWeeklyNotification(
    DateTime scheduleDate, Event event) async {
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
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
  );
}

Future<void> fetchAndScheduledEvents() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  int placeId = prefs.getString('placeId') as int;

  if (token != null) {
    try {
      final response = await http.get(
        Uri.parse('http://20.244.93.116/event/$placeId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> events = json.decode(response.body);

        // Cancel existing notifications
        await cancelAllNotifications();

        // Schedule new notifications
        await scheduleNotificationsFromSavedEvents(placeId);
      } else {
        print('Failed to fetch events');
      }
    } catch (error) {
      print('Error fetching events: $error');
    }
  }
}
