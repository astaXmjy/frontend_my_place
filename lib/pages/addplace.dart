import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final List<TextEditingController> _eventStartControllers =
      List.generate(6, (_) => TextEditingController());
  final List<TextEditingController> _eventEndControllers =
      List.generate(6, (_) => TextEditingController());
  final List<String> _eventNames = [
    'Fazar',
    'Johar',
    'Azar',
    'Magrib',
    'Isha',
    'Jumma'
  ];

  LatLng? _selectedLocation;
  bool _isSubmitting = false;

  Future<void> _getCoordinatesFromAddress() async {
    String address = _addressController.text;
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _selectedLocation = LatLng(location.latitude, location.longitude);
        });
      }
    } catch (e) {
      print("Error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get location coordinates.")),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCoordinatesFromAddress();
    } else {
      print("Location permission denied");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission is required to continue.")),
      );
    }
  }

  Future<void> _addEvents(int placeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: JWT token not found.")),
      );
      return;
    }

    List<Map<String, dynamic>> eventList = [];
    for (int i = 0; i < 6; i++) {
      String startTime = _eventStartControllers[i].text;
      String endTime = _eventEndControllers[i].text;

      if (startTime.isEmpty || endTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Please fill in all start and end times for the events.")),
        );
        return;
      }

      eventList.add({
        "name": _eventNames[i],
        "Azan": startTime,
        "Jamat": endTime,
        "place_id": placeId,
      });
    }

    try {
      final response = await http.post(
        Uri.parse('http://20.244.93.116/event'),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(eventList),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Events added successfully!")),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add events: ${response.body}")),
        );
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while adding the events.")),
      );
    }
  }

  Future<void> _submitPlace() async {
    final String name = _nameController.text;
    final String address = _addressController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (_selectedLocation == null || name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please complete all fields and get coordinates.")),
      );
      return;
    }

    final double latitude = _selectedLocation!.latitude;
    final double longitude = _selectedLocation!.longitude;

    setState(() {
      _isSubmitting = true;
    });

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: JWT token not found.")),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    Map<String, dynamic> placeData = {
      "name": name,
      "address": address,
      "lat": latitude,
      "long": longitude,
    };

    try {
      final response = await http.post(
        Uri.parse('http://20.244.93.116/places'),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(placeData),
      );

      if (response.statusCode == 201) {
        int placeId = await json.decode(response.body)['id'];
        await _addEvents(placeId); // Add events after creating the place
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add place: ${response.body}")),
        );
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while adding the place.")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Mosque'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Mosque Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.gps_fixed_rounded),
                  onPressed: _requestLocationPermission,
                ),
                Text(
                  'Fetch Coordinates',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            for (int i = 0; i < 6; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _eventNames[i],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _eventStartControllers[i].text =
                                    pickedTime.format(context);
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _eventStartControllers[i].text.isEmpty
                                  ? 'Azaan'
                                  : _eventStartControllers[i].text,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _eventEndControllers[i].text =
                                    pickedTime.format(context);
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _eventEndControllers[i].text.isEmpty
                                  ? 'Jamat'
                                  : _eventEndControllers[i].text,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPlace,
              child: _isSubmitting ? CircularProgressIndicator() : Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
