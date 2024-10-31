import 'package:flutter/material.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber; // Phone number passed from SignupPage

  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  void _verifyOtp() {
    // Handle OTP verification here
    String otp = _otpController.text;
    Navigator.pushNamedAndRemoveUntil(context, '/home',
        (Route<dynamic> route)=>false,);
    // Proceed to next steps, e.g., navigating to another page if OTP is valid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            const Center(
              child: Image(
                image: AssetImage('assets/logo.png'),
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            // Verity OTP heading
            const Text(
              'Verity OTP',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Details will come here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Display phone number passed from the route
            TextFormField(
              initialValue: widget.phoneNumber,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Mobile No.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // OTP input field (using TextFormField for simplicity, you can replace it with Pinput)
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Send Password button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Verify'),
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