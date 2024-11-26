import 'package:frontend/audio_background/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<List<Event>> getSavedEventsFromLocalStorage(int placeId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final eventsJson = prefs.getString('event_scheduled');

  if (eventsJson != null) {
    final List<dynamic> eventList = json.decode(eventsJson);
    return eventList.map((e) => Event.fromJson(e)).toList();
  } else {
    print('No events found for Place ID $placeId.');
    return [];
  }
}
