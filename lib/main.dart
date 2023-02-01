// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'authentication/authentication.dart';
import 'authentication/sign_in.dart';
import 'firebase_options.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AwesomeNotifications().initialize(
  //   // set the icon to null if you want to use the default app icon
  //     'resource://drawable/res_app_icon',
  //     [
  //       NotificationChannel(
  //           channelGroupKey: 'basic_channel_group',
  //           channelKey: 'basic_channel',
  //           channelName: 'Basic notifications',
  //           channelDescription: 'Notification channel for basic tests',
  //           defaultColor: Color(0xFF9D50DD),
  //           ledColor: Colors.white)
  //     ],
  //     debug: true
  // );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Running");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
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
      title: 'Bier Brouwen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthenticationPage()
    );
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
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              final firebaseUser = snapshot.data;
              if (firebaseUser == null) {
                return SizedBox(height: 30, width: 100, child: SignInScreen());
              }
              Authentication.email = firebaseUser.email;
              return HomePage();
            default:
              return Container(
                  constraints: BoxConstraints(maxWidth: 1000),
                  child: Center(
                    child: ElevatedButton(
                        onPressed: () =>
                            Authentication.signInWithGoogle(context: context),
                        child: Text("Inloggen met Google")),
                  ));
          }
        });
  }
}
//
// class NotificationController {
//
//   /// Use this method to detect when a new notification or a schedule is created
//   @pragma("vm:entry-point")
//   static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
//     // Your code goes here
//   }
//
//   /// Use this method to detect every time that a new notification is displayed
//   @pragma("vm:entry-point")
//   static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
//     // Your code goes here
//   }
//
//   /// Use this method to detect if the user dismissed a notification
//   @pragma("vm:entry-point")
//   static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
//     // Your code goes here
//   }
//
//   /// Use this method to detect when the user taps on a notification or action button
//   @pragma("vm:entry-point")
//   static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
//     // Your code goes here
//
//     // Navigate into pages, avoiding to open the notification details page over another details page already opened
//     MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
//             (route) => (route.settings.name != '/notification-page') || route.isFirst,
//         arguments: receivedAction);
//   }
// }
