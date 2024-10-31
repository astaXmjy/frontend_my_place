 import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  bool _agreeTerms = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }
  void _submitForm() {
    if (_formKey.currentState!.validate() && _agreeTerms) {
      // Handle signup logic here, e.g., navigate to the next screen
      String mobileNumber = _mobileController.text;
      print('Mobile Number: $mobileNumber');

      // Navigate to the OTP page
      Navigator.pushReplacementNamed(context, '/pin',arguments: mobileNumber );
    } else if (!_agreeTerms) {
      // Show an error message or snackbar if terms are not agreed to
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms and conditions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                // Logo Image
                Image.asset('assets/logo.png', height: 150),
                const SizedBox(height: 20),
                // Mobile number input field
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    // Add more validation if needed (e.g., phone number format)
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Terms & Conditions checkbox
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _agreeTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeTerms = value!;
                        });
                      },
                    ),
                    const Text("I Agree with terms & conditions"),
                  ],
                ),
                const SizedBox(height: 20),
                // Signup button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.green, // Background color
                    ),
                    onPressed: _submitForm,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Signup'),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),

                // Decorative footer elements

                const SizedBox(height:10),
                TextButton(
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Already have an account?',
                    style: TextStyle(
                      color: Colors.blue
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
          Positioned(
            bottom: 0, // Remove bottom padding
            left: 0, // Remove left padding
            right: 0, // Remove right padding
            child: Image.asset(
              'assets/footer.png',
              fit: BoxFit.cover,
            ),
          ),
    ]
      ),
    );
  }
}
