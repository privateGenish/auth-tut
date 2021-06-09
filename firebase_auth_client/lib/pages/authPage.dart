import 'package:firebase_auht_client/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key? key}) : super(key: key);

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.userChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          return HomePage();
        }
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Log in'),
              Padding(padding: EdgeInsets.all(8.0)),
              TextButton.icon(
                  onPressed: () {},
                  icon: FaIcon(FontAwesomeIcons.google),
                  label: Text("Google")),
              Padding(padding: EdgeInsets.all(8.0)),
              TextButton.icon(
                  onPressed: () {},
                  icon: FaIcon(FontAwesomeIcons.facebook),
                  label: Text("Facebook")),
            ],
          ),
        );
      },
    );
  }
}
