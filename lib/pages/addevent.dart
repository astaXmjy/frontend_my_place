import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For time formatting
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key, required this.placeId});
  final int placeId;

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  List<EventItem> _events = [EventItem()]; // Start with one empty event
  bool _isSubmitting = false;

  String _formatTime(TimeOfDay time) {
    final DateFormat formatter = DateFormat('HH:mm:ss');
    final DateTime dateTime = DateTime(2022, 1, 1, time.hour, time.minute);
    return formatter.format(dateTime);
  }

  Future<void> _submitEvents() async {
    // Check if all fields are completed
    if (_events.any((event) =>
        event.nameController.text.isEmpty ||
        event.startTime == null ||
        event.endTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all event fields.")),
      );
      return;
    }

    // Prepare the list of events
    List<Map<String, dynamic>> eventsData = _events.map((event) {
      return {
        "name": event.nameController.text,
        "start_time": _formatTime(event.startTime!),
        "end_time": _formatTime(event.endTime!),
        "place_id": widget.placeId, // Replace with actual place_id if needed
      };
    }).toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: JWT token not found.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://20.244.93.116/event'), // Replace with your API endpoint
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(eventsData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Events added successfully!")),
        );
        Navigator.pop(context, true); // Go back after submitting
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add events: ${response.body}")),
        );
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while adding events.")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _addEvent() {
    setState(() {
      _events.add(EventItem());
    });
  }

  void _removeEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
  }

  Future<void> _selectTime(
      BuildContext context, int index, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _events[index].startTime = picked;
        } else {
          _events[index].endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Events'),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _events[index].nameController,
                            decoration: InputDecoration(
                              labelText: 'Event Name',
                              labelStyle: TextStyle(color: Colors.green),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _selectTime(context, index, true),
                                  child: AbsorbPointer(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: _events[index].startTime != null
                                            ? _events[index]
                                                .startTime!
                                                .format(context)
                                            : '',
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Start Time',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _selectTime(context, index, false),
                                  child: AbsorbPointer(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: _events[index].endTime != null
                                            ? _events[index]
                                                .endTime!
                                                .format(context)
                                            : '',
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'End Time',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_events.length > 1)
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeEvent(index),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addEvent,
              child: Text("Add Another Event"),
            ),
            SizedBox(height: 20),
            _isSubmitting
                ? CircularProgressIndicator(color: Colors.green)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _submitEvents,
                    child:
                        Text('Submit Events', style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}

class EventItem {
  TextEditingController nameController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int? placeId;
}
