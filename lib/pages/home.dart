import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/audio_background/event.dart';
import 'package:frontend/audio_background/eventscheduler.dart';
import 'package:frontend/pages/addplace.dart';
import 'package:frontend/pages/contactus.dart';
import 'package:frontend/pages/createdplace.dart';
import 'package:frontend/pages/placedetail.dart';
import 'package:frontend/pages/placeitem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _subscribedPlaces = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  String? user_type;

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
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          List<dynamic> placesData = json.decode(response.body);

          setState(() {
            _subscribedPlaces = placesData.map((place) {
              return {
                'id': place['id'],
                'name': place['name']?.toString() ?? 'Unnamed Place',
                'address':
                    place['address']?.toString() ?? 'No Address Provided',
                'status': place['status'] ?? 'Unknown',
                'created_by': place['created_by'],
              };
            }).toList();
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

  Future<void> _searchPlaces(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://20.244.93.116/places/search?query=$query'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          List<dynamic> resultsData = json.decode(response.body);

          setState(() {
            _searchResults = resultsData.map((place) {
              return {
                'id': place['id'],
                'name': place['name']?.toString() ?? 'Unnamed Place',
                'address':
                    place['address']?.toString() ?? 'No Address Provided',
                'status': place['status'] ?? 'Unknown',
              };
            }).toList();
          });
        } else {
          print('Failed to fetch search results');
        }
      } catch (error) {
        print('Error searching places: $error');
      }
    } else {
      print('No token found');
    }
  }

  Future<void> _subscribeToPlace(int placeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('http://20.244.93.116/addplace/$placeId'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          print('Subscribed successfully');
          // Refresh subscribed places
          _fetchSubscribedPlaces();
        } else {
          print('Failed to subscribe');
        }
      } catch (error) {
        print('Error subscribing to place: $error');
      }
    } else {
      print('No token found');
    }
  }

  Future<void> _fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
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
          user_type = jsonResponse['user_type'];
        });
        print(user_type);
      } else {
        print('Failed to get current user id');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<void> fetchEvents(int placeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final resposne = await http.get(
      Uri.parse('http://20.244.93.116/event/$placeId'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resposne.statusCode == 200) {
      final List<dynamic> eventList = json.decode(resposne.body);
      final events = eventList.map((e) => Event.fromJson(e)).toList();
      final String eventsJson = json.encode(eventList);
      await prefs.setString('event_scheduled', eventsJson);
      await prefs.setInt('placeId', placeId);
    } else {
      throw Exception('Failed  to load events');
    }
  }

  Future<bool> _confirmEventSubscription(
      BuildContext context, String placeName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Subscribe to Event'),
            content:
                Text('Do you want to subscribe to events for "$placeName"? '
                    'This will replace any existing event notification.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> fetchAndScheduleEvents(int placeId) async {
    try {
      print('Fetching events for palceId: $placeId');
      await fetchEvents(placeId);

      await cancelAllNotifications();

      await scheduleNotificationsFromSavedEvents(placeId);
      print('Notifications scheduled for events.');
    } catch (e) {
      print(placeId);
      print('Error scheduling notifications from home: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    Workmanager().registerPeriodicTask(
        "eventSchedularTask", "fetchAndScheduledEvents",
        frequency: Duration(hours: 24));
    _fetchUserDetails();
    _fetchSubscribedPlaces();
    requestNotificationPermissions();
  }

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permissions');
    } else {
      print("User declined or has not accepted notification permissions");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search places...',
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });

            if (value.isNotEmpty) {
              _searchPlaces(value);
            } else {
              setState(() {
                _searchResults = [];
              });
            }
          },
        ),
      ),
      body: _getSelectedPageContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          if (user_type != 'regular')
            const BottomNavigationBarItem(
              icon: Icon(Icons.place),
              label: 'Places',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact Us',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
      floatingActionButton: user_type != 'regular'
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPlaceScreen()),
              ).then((value) {
                if (value == true) _fetchSubscribedPlaces();
              }),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _getSelectedPageContent() {
    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }

    switch (_selectedIndex) {
      case 0:
        return _buildSubscribedPlacesList();
      case 1:
        return user_type != 'regular' ? CreatedPlacePage() : ContactUsPage();
      case 2:
        return const ContactUsPage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        final isSubscribed = _subscribedPlaces.any((subPlace) =>
            subPlace['id'] == place['id']); // Check if already subscribed

        return ListTile(
          title: Text(place['name']),
          subtitle: Text(place['address']),
          trailing: isSubscribed
              ? null
              : ElevatedButton(
                  onPressed: () {
                    _subscribeToPlace(place['id']);
                  },
                  child: const Text('Subscribe'),
                ),
        );
      },
    );
  }

  Widget _buildSubscribedPlacesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_subscribedPlaces.isEmpty) {
      return const Center(child: Text('No places subscribed.'));
    }

    return ListView.builder(
      itemCount: _subscribedPlaces.length,
      itemBuilder: (context, index) {
        final place = _subscribedPlaces[index];
        return PlaceListItem(
          place: place,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailScreen(place: place),
            ),
          ),
          onFetchEvent: () async {
            final confirmed =
                await _confirmEventSubscription(context, place['name']);
            if (confirmed) {
              await fetchAndScheduleEvents(place['id']);
            }
          },
        );
      },
    );
  }
}
