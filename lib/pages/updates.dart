import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatesPage extends StatefulWidget {
  final int placeId; // Accept place ID as argument

  const UpdatesPage({Key? key, required this.placeId}) : super(key: key);

  @override
  _UpdatesPageState createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _informationController = TextEditingController();

  File? _selectedImage;

  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to capture an image using the camera
  Future<void> _captureImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Gather form data
      final information = _informationController.text;
      final image = _selectedImage;

      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      try {
        // Fetch the token from shared preferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token == null) {
          throw Exception('No token found in shared preferences');
        }

        // API endpoint
        final uri = Uri.parse(
            'http://20.244.93.116/updates/${widget.placeId}?inf=$information');

        // Create multipart request
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['accept'] = 'application/json'
          ..files.add(await http.MultipartFile.fromPath(
            'file',
            image.path,
            contentType: MediaType('image', 'png'),
          ));

        // Send request
        final response = await request.send();
        print(response);

        if (response.statusCode == 200) {
          // Clear form and show success message
          _formKey.currentState!.reset();
          setState(() {
            _selectedImage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Update submitted successfully')),
          );
          Navigator.pop(context);
        } else {
          final responseBody = await response.stream.bytesToString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $responseBody')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Update'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information Field
                TextFormField(
                  controller: _informationController,
                  decoration: const InputDecoration(
                    labelText: 'Information',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter information';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image Picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _captureImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Display Selected Image
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                const SizedBox(height: 24),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit Update'),
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
