import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'authentication.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String email = "";
  String password = "";
  bool register = false;
  var error = '';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const SelectableText('Beer Brewer')),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (Authentication.error != null) Text(Authentication.error!, style: const TextStyle(color: Colors.red),),
                  Container(
                      padding: EdgeInsets.all(20),
                      child: SignInButton(
                          Buttons.Google,
                          text: "Log in met Google",
                          onPressed: () async {
                            await Authentication.signInWithGoogle(
                                context: context);
                          }
                      )
                  ),
                ])));
  }

}
