import 'package:beer_brewer/authentication/sign_in.dart';
import 'package:beer_brewer/batch/batches_overview.dart';
import 'package:beer_brewer/data/database_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {

  static String? error;
  static String? email;

  handleAuthState() {
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
              return const BatchesOverview();
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

  static Future<String?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      authProvider.setCustomParameters({
        'prompt': 'select_account'
      });

      try {
        final UserCredential userCredential =
        await auth.signInWithPopup(authProvider);
        user = userCredential.user;
        // if (!allowedEmails.contains(user?.email!.toLowerCase())) {
        //   error = "Gebruiker heeft geen toegang tot deze app.";
        //   auth.signOut();
        // } else {
        //   error = null;
        // }
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
          await auth.signInWithCredential(credential);

          user = userCredential.user;
          // if (!allowedEmails.contains(user?.email!.toLowerCase())) {
          //   error = "Gebruiker heeft geen toegang tot deze app.";
          //   auth.signOut();
          // } else {
          //   error = null;
          // }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // ...
          } else if (e.code == 'invalid-credential') {
            // ...
          }
        } catch (e) {
          // ...
        }
      }
    }

    return error;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      email = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: SelectableText(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}
class UserOrErrorMessage {
  User? user;
  String? errorMessage;

  UserOrErrorMessage({this.user, this.errorMessage});
}
