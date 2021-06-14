import 'package:firebase_auht_client/models/authModel.dart';
import 'package:firebase_auht_client/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  Future<String> _getAuthMethod() async {
    final pref = await SharedPreferences.getInstance();
    try {
      final state = pref.getString('Auth-Method')!.toUpperCase();
      print(state);
      return state;
    } catch (e) {
      return 'NULL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<AuthModel>(context).auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.data is User) {
          return HomePage();
        }
        return FutureBuilder(
          future: _getAuthMethod(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == 'GOOGLE') {
              return FutureBuilder(
                future: Provider.of<AuthModel>(context, listen: false)
                    .handleGoogleSilentSignIn(context),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == null) {
                    return _loginPage(context);
                  }
                  return _splashScreen();
                },
              );
            }
            if (snapshot.data == 'FACEBOOK') {
              if (Provider.of<AuthModel>(context).facebookAuth.accesskey !=
                  null) {
                Provider.of<AuthModel>(context)
                    .handleFacebookSilentLogin(context);
              }
              return _splashScreen();
            }
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data == 'NULL') {
              return _loginPage(context);
            }
            return _splashScreen();
          },
        );
      },
    );
  }

  Widget _loginPage(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Log in'),
              Padding(padding: EdgeInsets.all(8.0)),
              TextButton.icon(
                  onPressed: () async =>
                      await Provider.of<AuthModel>(context, listen: false)
                          .handleGoogleSignIn(context),
                  icon: FaIcon(FontAwesomeIcons.google),
                  label: Text("Google")),
              TextButton.icon(
                  onPressed: () async =>
                      await Provider.of<AuthModel>(context, listen: false)
                          .handleFacebookSignIn(context),
                  icon: FaIcon(FontAwesomeIcons.facebook),
                  label: Text("Facebook")),
              TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_context) => EmailPage(context: context))),
                  icon: Icon(Icons.email),
                  label: Text("Email")),
            ],
          ),
        ),
      );

  Widget _splashScreen() => Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlutterLogo(
              size: 48,
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Container(
                height: 24,
                width: 24,
                child: CircularProgressIndicator.adaptive())
          ],
        ),
      );

  Widget _emailRegisterScreen(context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome abourd!",
                style: Theme.of(context).textTheme.headline1,
              ),
            ]),
      ),
    );
  }
}

class EmailPage extends StatefulWidget {
  const EmailPage({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _EmailPageState createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  @override
  Widget build(BuildContext _context) {
    final GlobalKey<FormFieldState> _passwordKey = GlobalKey();
    final GlobalKey<FormFieldState> _emailKey = GlobalKey();
    return Material(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  key: _emailKey,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  key: _passwordKey,
                  decoration: InputDecoration(labelText: 'password'),
                  validator: (str) {
                    if (str == null || str.length < 8) {
                      return 'Password is short';
                    }
                  },
                ),
                ElevatedButton.icon(
                    onPressed: () async {
                      if (_passwordKey.currentState!.validate()) {
                        switch (await Provider.of<AuthModel>(widget.context,
                                listen: false)
                            .handleEmailSignIn(
                                email: _emailKey.currentState!.value,
                                password: _passwordKey.currentState!.value)) {
                          case 'user-not-found':
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text("User Not Found!")));
                            break;
                        }
                      }
                    },
                    icon: Icon(Icons.email),
                    label: Text('Log in / Sign Up'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
