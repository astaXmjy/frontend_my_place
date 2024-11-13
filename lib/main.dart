import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/loading.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/pin.dart';
import 'package:frontend/pages/signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // get phoneNumber => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoadingPage(), // Set LoadingPage as the initial screen
      routes: {
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignupScreen(),
        '/pin': (context) => PinSetupScreen(),
        // '/otp': (context) => OtpPage(
        //     phoneNumber: ModalRoute.of(context)!.settings.arguments as String,verificationId: ModalRoute.of(context),),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
