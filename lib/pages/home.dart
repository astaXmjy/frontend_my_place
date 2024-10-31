import 'package:flutter/material.dart';
import 'package:frontend/pages/contactus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Bottom navigation index

  // Dummy data for subscribed places (replace with real data)
  final List<String> _subscribedPlaces = [
    'x_place',
    'y_place',
    'z_place',
    'a_place',
    'b_place',
  ];

  // Bottom navigation item tap handler
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location),
            label: 'Add Place',
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
    );
  }

  // Get content based on selected tab
  Widget _getSelectedPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildSubscribedPlacesList();
      case 1:
        return const CreateNewPlaceScreen();
      case 2:
        return const CreatedPlacesScreen();
      case 3:
        return const ContactUsPage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  // Widget to display the list of subscribed places
  Widget _buildSubscribedPlacesList() {
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
              title: Text(_subscribedPlaces[index]),
              onTap: () {
                // Action when place is tapped (e.g., navigate to details)
                print('Tapped on ${_subscribedPlaces[index]}');
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
    return Center(
      child: Text(
        'Created Places Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Placeholder screen for Contact Us