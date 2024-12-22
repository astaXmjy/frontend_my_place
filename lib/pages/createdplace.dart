import 'package:flutter/material.dart';
import 'package:frontend/pages/placedetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreatedPlacePage extends StatefulWidget {
  const CreatedPlacePage({super.key});

  @override
  _CreatedPlacePageState createState() => _CreatedPlacePageState();
}

class _CreatedPlacePageState extends State<CreatedPlacePage> {
  List<Map<String, dynamic>> places = [];

  @override
  void initState() {
    super.initState();
    _fetchCreatedPlaces();
  }

  Future<void> _fetchCreatedPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); // Retrieve stored token

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://20.244.93.116/users_places'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          places = data.map((place) {
            return {
              'id': place['id'],
              'name': place['name'],
              'address': place['address'],
              'created_by': place['created_by']
            };
          }).toList();
        });
      } else {
        print('Failed to fetch places: ${response.statusCode}');
      }
    } else {
      print('JWT token not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mosque', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: places.isEmpty
          ? Center(
              child: Text('No created places found'),
            )
          : ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailScreen(place: place),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            place['address'],
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => _updatePlace(place['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _updatePlace(int placeId) {
    Navigator.pushNamed(context, '/updatePlace', arguments: placeId);
  }
}
