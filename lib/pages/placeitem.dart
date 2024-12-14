import 'package:flutter/material.dart';
import 'package:frontend/audio_background/eventscheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceListItem extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onTap;
  final VoidCallback onFetchEvent;

  const PlaceListItem({
    required this.place,
    required this.onTap,
    required this.onFetchEvent,
    Key? key,
  }) : super(key: key);

  Future<void> _cancelNotificationsAndClearData(BuildContext context) async {
    // Cancel all scheduled notifications
    await flutterLocalNotificationsPlugin.cancelAll();

    // Clear all event data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('events');
    await prefs.remove('placeId');

    // Show a snackbar as feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifications canceled and event data cleared.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: const Text(
            'Are you sure you want to cancel all notifications and clear event data?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _cancelNotificationsAndClearData(context);
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: const Icon(Icons.place, color: Colors.green),
        title: Text(place['name']!),
        subtitle: Text(place['address']!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onFetchEvent,
              icon: const Icon(Icons.notifications, color: Colors.green),
              tooltip: 'get notifications of events',
            ),
            IconButton(
              onPressed: () => _showCancelConfirmationDialog(context),
              icon: const Icon(
                Icons.notifications_off,
                color: Colors.red,
              ),
              tooltip: 'Cancel notification and clear events',
            )
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
