import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false; // To show loading indicator during login

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Function to handle login and store token
  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      String mobileNumber = _phoneController.text;
      String pin = _pinController.text;

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

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          await _secureStorage.write(key: "mobile_number", value: mobileNumber);
          await _secureStorage.write(key: 'pin', value: pin);

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid credentials')),
          );
        }
      } catch (error) {
        print('Error during login: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.1),

                // Logo
                const Center(
                  child: Image(
                    image: AssetImage('assets/logo.png'),
                    height: 100,
                  ),
                ),
                const SizedBox(height: 20),

                // Login heading
                const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Mobile Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile No.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.length != 10) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // PIN label
                const Text(
                  'Enter 4-digit PIN',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                // PIN input field
                Pinput(
                  controller: _pinController,
                  length: 4,
                  obscureText: true,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length != 4) {
                      return 'PIN should be 4 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Login Button with Loading Indicator
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator() // Show progress indicator when loading
                        : const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Signup Button
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/signup'); // Route to signup page
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
