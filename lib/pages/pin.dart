import 'package:flutter/material.dart';
import 'package:frontend/pages/otp.dart';
import 'package:pinput/pinput.dart';

class PinSetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String mobileNumber =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Logo Image
            Image.asset(
              'assets/logo.png', // Replace with your logo asset
              height: 150,
            ),
            SizedBox(height: 40),
            // Set Pin field
            PinInputSection(label: 'Set Pin'),
            SizedBox(height: 20),
            // Verify Pin field
            PinInputSection(label: 'Verify Pin'),
            SizedBox(height: 40),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Colors.green, // Background color
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/otp',arguments:mobileNumber);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Save'),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward),
                  ],
                ),
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

  PinInputSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Pinput(
          length: 4,
          showCursor: true,
          onChanged: (pin) {
            // Handle logic for PIN input
            print('Pin entered: $pin');
          },
          onCompleted: (pin) {
            // Handle logic when PIN is fully entered
            print('Pin completed: $pin');
          },
          defaultPinTheme: PinTheme(
            width: 60,
            height: 60,
            textStyle: TextStyle(fontSize: 20, color: Colors.black),
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
