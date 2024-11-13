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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Place added successfully!")),
        );
        Navigator.pop(context);
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
        title: Text(
          'Add Mosque',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mosque Details',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.green),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Address Details',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(color: Colors.green),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.location_on, color: Colors.green),
                  onPressed: _requestLocationPermission,
                ),
              ],
            ),
            SizedBox(height: 20),
            _isSubmitting
                ? Center(child: CircularProgressIndicator(color: Colors.green))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _submitPlace,
                    child: Text('Add Place', style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}
