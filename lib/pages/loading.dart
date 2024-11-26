import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    String? mobileNumber = await _secureStorage.read(key: "mobile_number");
    String? pin = await _secureStorage.read(key: 'pin');

    if (mobileNumber != null && pin != null) {
      final success = await _loginWithStoredCredentials(mobileNumber, pin);
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
    }
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<bool> _loginWithStoredCredentials(
      String mobileNumber, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('http://20.244.93.116/login'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'password',
          'username': mobileNumber,
          'password': pin,
          'scope': '',
          'client_id': 'string',
          'client_secret': 'string',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];

        // Update the auth token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return true;
      }
    } catch (error) {
      print('Error during auto-login: $error');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.png'), // Replace with your image path
          fit: BoxFit.cover, // Cover the entire screen
        ),
      ),
    ));
  }
}
