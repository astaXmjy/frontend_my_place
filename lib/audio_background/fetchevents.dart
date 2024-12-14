import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> fetchEventsPlaceSaved() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  int? placeId = prefs.getInt('placeId');

  if (placeId == null) {
    print('no placeId found in local storage. Exiting.');
    return;
  }
  try {
    final resposne = await http.get(
      Uri.parse('http://20.244.93.116/event/$placeId'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resposne.statusCode == 200) {
      final List<dynamic> eventList = json.decode(resposne.body);
      final List<dynamic> filteredEvents = eventList.map((event) {
        return {
          "name": event['name'],
          'start_time': event['start_time'],
        };
      }).toList();
      print(jsonEncode(filteredEvents));
      await prefs.setString('events', jsonEncode(filteredEvents));
    } else {
      print(placeId);
      throw Exception('Failed  to load events');
    }
  } catch (e) {
    print('Error occured: $e');
    rethrow;
  }
}
