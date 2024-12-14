import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/audio_background/eventscheduler.dart';
import 'package:frontend/audio_background/fetchevents.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/flutterpushnotifications/pushnotifications.dart';
import 'package:frontend/pages/addevent.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/loading.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/pin.dart';
import 'package:frontend/pages/signup.dart';
import 'package:frontend/pages/updates.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  if (message.data.containsKey('action') &&
      message.data['action'] == 'fetch_updated_event') {
    print('this is for background');

    await cancelAllNotifications();

    await fetchEventsPlaceSaved();

    await scheduleDailyNotificationsFromStorage();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  NotificationService notificationService = NotificationService();

  await notificationService.initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.light(
          primary: Colors.green,
          secondary: Colors.greenAccent, // This is where accentColor would be
        ),
      ),
      home: const LoadingPage(), // Set LoadingPage as the initial screen
      routes: {
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignupScreen(),
        '/pin': (context) => PinSetupScreen(),
        '/login': (context) => const LoginPage(),
        '/addEvent': (context) => AddEventScreen(
            placeId: ModalRoute.of(context)!.settings.arguments as int),
        '/updatePlace': (context) => UpdatesPage(
            placeId: ModalRoute.of(context)!.settings.arguments as int),
      },
    );
  }
}
