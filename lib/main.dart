import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/audio_background/eventscheduler.dart';
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
import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await fetchAndScheduledEvents();
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      .requestNotificationsPermission();
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
        // '/otp': (context) => OtpPage(
        //     phoneNumber: ModalRoute.of(context)!.settings.arguments as String,verificationId: ModalRoute.of(context),),
        '/login': (context) => const LoginPage(),
        // '/addplace':(context)=> const AddPlaceScreen()
        '/addEvent': (context) => AddEventScreen(
            placeId: ModalRoute.of(context)!.settings.arguments as int),
        '/updatePlace': (context) => UpdatesPage(
            placeId: ModalRoute.of(context)!.settings.arguments as int),
      },
    );
  }
}
// class MyApp extends StatelessWidget {
//   @overrides
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotificationTestPage(),
//     );
//   }
// }
//
// class NotificationTestPage extends StatefulWidget {
//   @override
//   _NotificationTestPageState createState() => _NotificationTestPageState();
// }
//
// class _NotificationTestPageState extends State<NotificationTestPage> {
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeNotifications();
//   }
//
//   void initializeNotifications() async {
//     // Initialize timezone data
//     tz.initializeTimeZones();
//
//     // Create a FlutterLocalNotificationsPlugin instance
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//     const AndroidInitializationSettings androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: androidInitializationSettings,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   void scheduleNotification() async {
//     // Define notification details
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       channelDescription: 'Test Channel for Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//     );
//
//     // Schedule the notification 5 seconds from now
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0, // Notification ID
//       'Scheduled Notification', // Title
//       'This is a test notification', // Body
//       tz.TZDateTime.now(tz.local)
//           .add(const Duration(seconds: 60)), // Scheduled time
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//
//     print('Notification scheduled!');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notification Test')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: scheduleNotification,
//           child: const Text('Schedule Notification'),
//         ),
//       ),
//     );
//   }
// }
