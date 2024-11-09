import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// HomePage with Bottom Navigation and API fetching
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Bottom navigation index
  List<Map<String, dynamic>> _subscribedPlaces = []; // List to hold places data

  // Bottom navigation item tap handler
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fetch subscribed places from the API
  Future<void> _fetchSubscribedPlaces() async {
    // Get token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null) {
      try {
        // Make the API request to fetch places
        final response = await http.get(
          Uri.parse(
              'http://20.244.93.116/users/places'), // Replace with your API endpoint
          headers: {
            'Authorization':
                'Bearer $token', // Sending token in the authorization header
          },
        );

        if (response.statusCode == 200) {
          // Parse the response
          List<dynamic> placesData = json.decode(response.body);
          setState(() {
            _subscribedPlaces = placesData
                .map((place) => {
                      'name': place['name'] ??
                          'Unnamed Place', // Safely get place name
                      'address': place['address'] ??
                          'No Address Provided', // Safely get address
                    })
                .toList();
          });
        } else {
          // Handle the error if the response is not successful
          print('Failed to load places');
        }
      } catch (error) {
        // Handle any errors during the API request
        print('Error fetching places: $error');
      }
    } else {
      print('No token found');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSubscribedPlaces(); // Fetch the places when the page loads
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
      // Bottom Navigation Bar without the "Add Place" button
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
      // Add floating action button for adding new place
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create New Place Screen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateNewPlaceScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Get content based on selected tab
  Widget _getSelectedPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildSubscribedPlacesList();
      case 1:
        return const CreatedPlacesScreen();
      case 2:
        return const ContactUsPage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  // Widget to display the list of subscribed places
  Widget _buildSubscribedPlacesList() {
    if (_subscribedPlaces.isEmpty) {
      return const Center(
          child: CircularProgressIndicator()); // Show loading indicator
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
                // Action when place is tapped (e.g., navigate to details)
                print('Tapped on ${_subscribedPlaces[index]['name']}');
              },
            ),
          );
        },
      ),
    );
  }
}

// Placeholder screen for Create New Place
class CreateNewPlaceScreen extends StatelessWidget {
  const CreateNewPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Create New Place Screen',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement create new place functionality
            },
            child: const Text('Add New Place'),
          ),
        ],
      ),
    );
  }
}

// Placeholder screen for Created Places
class CreatedPlacesScreen extends StatelessWidget {
  const CreatedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Created Places Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Placeholder Contact Us Page
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contact Us Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
