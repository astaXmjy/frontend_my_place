import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initializeFirebase() async {
    final String? _deviceToken = await _messaging.getToken();
    print('Device Token: $_deviceToken');

    if (_deviceToken != null) {
      await sendDeviceTokenToBackend(_deviceToken);
    }
  }

  Future<void> sendDeviceTokenToBackend(String _devicetoken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    const String apiUrl = "http://20.244.93.116/update/user";

    if (token == null) {
      print("Bearer token not found in SharedPreferences");
    }
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"device_id": _devicetoken}),
      );
      if (response.statusCode == 200) {
        print("Device token updated successfully on the server");
      } else {
        print("Failed to update device token. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending device token to backend: $e");
    }
  }
}
