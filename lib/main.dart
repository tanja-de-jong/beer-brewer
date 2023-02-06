import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:beer_brewer/data/store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'authentication/authentication.dart';
import 'batch/batch_details.dart';
import 'firebase_options.dart';
import 'models/batch.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      //   'resource://drawable/res_app_icon',
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      debug: true);
  // MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // @override
  // void initState() {
  //   // Only after at least the action method is set, the notification events are delivered
  //   AwesomeNotifications().setListeners(
  //       onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
  //       onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
  //       onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
  //       onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
  //   );

  //   super.initState();
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        title: 'Bier Brouwen',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthenticationPage());
  }
}

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Authentication().handleAuthState();
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
    if (receivedAction.payload != null &&
        receivedAction.payload!.containsKey("batch")) {
      await Store.loadData();

      Iterable<Batch> batches = Store.batches
          .where((element) => element.id == receivedAction.payload!["batch"]!);
      if (batches.isNotEmpty) {
        MyApp.navigatorKey.currentState?.push(MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                BatchDetails(batch: batches.first)));
      }
    }
  }
}
