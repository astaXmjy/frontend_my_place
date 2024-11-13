import 'package:flutter/material.dart';
import 'package:frontend/pages/addplace.dart';
import 'package:frontend/pages/contactus.dart';
import 'package:frontend/pages/createdplace.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, String>> _subscribedPlaces = [];
  bool _isLoading = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchSubscribedPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://20.244.93.116/users/places'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          print(token);
          List<dynamic> placesData = json.decode(response.body);

          setState(() {
            _subscribedPlaces = placesData
                .map((place) => {
                      'name': place['name']?.toString() ?? 'Unnamed Place',
                      'address':
                          place['address']?.toString() ?? 'No Address Provided',
                    })
                .toList()
                .cast<Map<String, String>>();
            _isLoading = false;
          });
        } else {
          print('Failed to load places');
          setState(() {
            _isLoading = false;
          });
        }
      } catch (error) {
        print('Error fetching places: $error');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No token found');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSubscribedPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search places...',
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _getSelectedPageContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Places',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact Us',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPlaceScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _getSelectedPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildSubscribedPlacesList();
      case 1:
        return const CreatedPlaceScreen();
      case 2:
        return const ContactUsPage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildSubscribedPlacesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_subscribedPlaces.isEmpty) {
      return const Center(child: Text('No places subscribed.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _subscribedPlaces.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: const Icon(Icons.place, color: Colors.green),
              title: Text(_subscribedPlaces[index]['name']!),
              subtitle: Text(_subscribedPlaces[index]['address']!),
              onTap: () {
                print('Tapped on ${_subscribedPlaces[index]['name']}');
              },
            ),
          );
        },
      ),
    );
  }
}
