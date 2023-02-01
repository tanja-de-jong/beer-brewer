import 'package:beer_brewer/batch/batches_overview.dart';
import 'package:beer_brewer/products_overview.dart';
import 'package:beer_brewer/recipe/recipe_creator.dart';
import 'package:beer_brewer/recipe/recipes_overview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'authentication/authentication.dart';
import 'authentication/sign_in.dart';
import 'firebase_options.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bier Brouwen',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const AuthenticationPage()
    );
  }
}

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
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
                // Expanded(child: SignInButton(
                //   Buttons.Google,
                //   text: "Log in met Google",
                //   onPressed: () =>
                //       Authentication.signInWithGoogle(context: context),
                // ));
              }
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
          //   Center(child: CircularProgressIndicator(
          //     valueColor: AlwaysStoppedAnimation<Color>(
          //       Colors.pink,
          //     )),
          // );
          }
        });
  }
}

