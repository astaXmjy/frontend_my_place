import 'dart:convert'; // For Base64 decoding
import 'dart:ffi';
import 'dart:typed_data'; // For ByteData
import 'package:flutter/material.dart';
import 'package:frontend/audio_background/eventscheduler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> updates = [];
  bool isLoadingEvents = true;
  bool isLoadingUpdates = true;
  String? token;
  int? user_id;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    if (token != null) {
      print(widget.place['created_by']);
      await Future.wait([_fetchEvents(), _fetchUpdates(), _fetchUserDetails()]);
    } else {
      print('Token not found');
      setState(() {
        isLoadingEvents = false;
        isLoadingUpdates = false;
      });
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://20.244.93.116/current_user'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          user_id = jsonResponse['id'];
        });
        print(user_id);
      } else {
        print('Failed to get current user id');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<void> _fetchEvents() async {
    final placeId = widget.place['id'];
    try {
      final response = await http.get(
        Uri.parse('http://20.244.93.116/event/$placeId'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          events = data
              .map((event) => {
                    'id': event['id'],
                    'name': event['name'],
                    'start_time': event['start_time'],
                    'end_time': event['end_time'],
                  })
              .toList();

          isLoadingEvents = false;
        });
      } else {
        print('Failed to fetch events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _fetchUpdates() async {
    final placeId = widget.place['id'];
    try {
      final response = await http.get(
        Uri.parse('http://20.244.93.116/places/$placeId/updates'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          updates = data
              .map((update) => {
                    'id': update['id'],
                    'created_at': update['created_at'],
                    'information': update['information'],
                    'image': update['image'],
                  })
              .toList();
        });
      } else {
        print('Failed to fetch updates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching updates: $e');
    } finally {
      setState(() => isLoadingUpdates = false);
    }
  }

  Future<void> _updateEvent(
      int eventId, String newStartTime, String newEndTime) async {
    final placeId = widget.place['id'];

    try {
      final response = await http.put(
        Uri.parse('http://20.244.93.116/event_update/$placeId/$eventId'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'start_time': newStartTime,
          'end_time': newEndTime,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        print('Event updated successfully');
        await _fetchEvents();
      } else {
        print('Failed to update event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  Future<void> _showEditPopup(
      int eventId, String currentStartTime, String currentEndTime) async {
    final startTimeController = TextEditingController(text: currentStartTime);
    final endTimeController = TextEditingController(text: currentEndTime);

    // Parse the time string to TimeOfDay objects
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    try {
      startTime = TimeOfDay.fromDateTime(
          DateFormat("yyyy-MM-ddTHH:mm:ss").parse(currentStartTime));
      endTime = TimeOfDay.fromDateTime(
          DateFormat("yyyy-MM-ddTHH:mm:ss").parse(currentEndTime));
    } catch (e) {
      print("Error parsing time: $e");
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Namaj'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Azan',
                    hintText: 'Enter start time',
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: startTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      startTime = pickedTime;
                      startTimeController.text = pickedTime.format(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Jamat',
                    hintText: 'Enter end time',
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: endTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      endTime = pickedTime;
                      endTimeController.text = pickedTime.format(context);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newStartTime = startTimeController.text.trim();
                final newEndTime = endTimeController.text.trim();

                if (newStartTime.isNotEmpty && newEndTime.isNotEmpty) {
                  await _updateEvent(eventId, newStartTime, newEndTime);
                  Navigator.pop(context);
                } else {
                  print("Start time or end time is empty.");
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventList() {
    if (isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    } else if (events.isEmpty) {
      return const Text('No events found for this place');
    }

    final smallTextStyle = TextStyle(fontSize: 16); // Smaller font size

    // Separate Jumma event and other events
    final List<Map<String, dynamic>> nonJummaEvents = [];
    Map<String, dynamic>? jummaEvent;

    for (var event in events) {
      if (event['name'].toLowerCase() == 'jumma') {
        jummaEvent = event;
      } else {
        nonJummaEvents.add(event);
      }
    }

    // Append Jumma event at the end if it exists
    if (jummaEvent != null) {
      nonJummaEvents.add(jummaEvent);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Enable vertical scrolling
        child: DataTable(
          horizontalMargin: 0,
          columnSpacing: 25,
          dataRowHeight: 30, // Reduce row height
          headingRowHeight: 40, // Reduce header row height
          columns: [
            DataColumn(
              label: Text('Namaj', style: smallTextStyle),
            ),
            DataColumn(
              label: Text('Azan', style: smallTextStyle),
            ),
            DataColumn(
              label: Text('Jamat', style: smallTextStyle),
            ),
            DataColumn(
              label: Text('', style: smallTextStyle),
            ),
          ],
          rows: nonJummaEvents.map((event) {
            final isCreatedByUser = widget.place['created_by'] == user_id;

            String formatTime(String time) {
              final parsedTime = DateFormat("hh:mm:ss").parse(time);
              return DateFormat("hh:mm a").format(parsedTime);
            }

            final formattedStartTime = formatTime(event['start_time']);
            final formattedEndTime = formatTime(event['end_time']);

            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                (states) {
                  // Highlight row if it's Jumma
                  if (event['name'].toLowerCase() == 'jumma') {
                    return Colors.green.withOpacity(0.4); // Highlight color
                  }
                  return null; // Default color
                },
              ),
              cells: [
                DataCell(Text(event['name'], style: smallTextStyle)),
                DataCell(Text(formattedStartTime, style: smallTextStyle)),
                DataCell(Text(formattedEndTime, style: smallTextStyle)),
                DataCell(
                  isCreatedByUser
                      ? IconButton(
                          icon: const Icon(Icons.edit,
                              size: 16, color: Colors.green), // Smaller icon
                          onPressed: () {
                            _showEditPopup(event['id'], event['start_time'],
                                event['end_time']);
                          },
                        )
                      : const SizedBox(), // Empty placeholder if not created by the user
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUpdateList() {
    if (isLoadingUpdates) {
      return const Center(child: CircularProgressIndicator());
    } else if (updates.isEmpty) {
      return const Text('No updates found for this place');
    }
    return ListView.builder(
      itemCount: updates.length,
      itemBuilder: (context, index) {
        final update = updates[index];
        String formatTime(String time) {
          final utcTime = DateTime.parse(time);
          final localTime = utcTime.toLocal();
          return DateFormat('MM/dd/yyyy hh:mm a').format(localTime);
        }

        Uint8List? imageBytes;
        if (update['image'] != null && update['image'].isNotEmpty) {
          imageBytes = base64Decode(update['image']);
        }
        return ListTile(
          title: Text(update['information']),
          subtitle: Text('Created at: ${formatTime(update['created_at'])}'),
          leading: imageBytes != null
              ? GestureDetector(
                  onTap: () {
                    // Show image in a dialog when clicked
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Image.memory(
                            imageBytes!,
                            width:
                                300, // Set a fixed width for the dialog image
                            height:
                                300, // Set a fixed height for the dialog image
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                  child: Image.memory(
                    imageBytes,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.image_not_supported),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place['name'],
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mosque Name',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.place['name'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Address',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.place['address'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Namaj Timings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Expanded(child: _buildEventList()),
            const SizedBox(height: 16),
            const Text('Updates',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Expanded(child: _buildUpdateList()),
          ],
        ),
      ),
    );
  }
}
