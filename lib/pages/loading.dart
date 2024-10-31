import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState(){
    super.initState();
    _navigateToSignUp();
  }
  Future<void> _navigateToSignUp() async{
    await Future.delayed(const Duration(seconds:3));
    Navigator.pushReplacementNamed(context, '/signup');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'), // Replace with your image path
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
        )
    );
  }
}