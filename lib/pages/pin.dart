import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'dart:convert';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String? _pin;
  bool _isLoading = false;

  // Signup method to send data to your API
  Future<void> _signup(String mobileNumber, String address, String pin) async {
    setState(() => _isLoading = true);
    const String apiUrl = 'http://20.244.93.116/users'; // Update as needed
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "mobile_no": mobileNumber,
          "address": address,
          "device_id": "string", // Include actual device ID if available
          "password": pin,
          "latitude": 0,
          "longitude": 0
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 201) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (Route<dynamic> route) => false,
        );
      } else {
        _showError("Signup failed. Please try again.");
      }
    } catch (e) {
      _showError("An error occurred. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Method to show error messages in SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String mobileNumber = args['mobileNumber']!;
    final String address = args['address']!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png', height: 150),
            const SizedBox(height: 40),
            PinInputSection(
              label: 'Enter 4-Digit PIN',
              onPinChanged: (pin) => setState(() => _pin = pin),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Colors.green,
                ),
                onPressed: (_pin?.length == 4 && !_isLoading)
                    ? () => _signup(mobileNumber, address, _pin!)
                    : null,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to create the Pin Input section with a label
class PinInputSection extends StatelessWidget {
  final String label;
  final ValueChanged<String> onPinChanged;

  const PinInputSection({
    required this.label,
    required this.onPinChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Pinput(
          length: 4,
          showCursor: true,
          onChanged: onPinChanged,
          defaultPinTheme: PinTheme(
            width: 60,
            height: 60,
            textStyle: const TextStyle(fontSize: 20, color: Colors.black),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
