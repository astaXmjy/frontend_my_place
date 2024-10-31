import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Help Center Header
            const Text(
              'Help Center',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'One line description if needed.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Phone Contact Section
            Column(
              children: [
                Icon(Icons.phone, color: Colors.green, size: 40),
                const SizedBox(height: 8),
                const Text(
                  '+91 98278 09593',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Feel free to contact us with any questions or concerns.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Email Contact Section
            Column(
              children: [
                Icon(Icons.email, color: Colors.green, size: 40),
                const SizedBox(height: 8),
                const Text(
                  'support@xyz.com',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'We are happy to assist you with any detailed inquiries by email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // FAQ Section
            Column(
              children: [
                Icon(Icons.help, color: Colors.green, size: 40),
                const SizedBox(height: 8),
                const Text(
                  "App Tutorials/Faq's",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Let us assist you with your questions, we have all the answers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


