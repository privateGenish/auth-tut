import 'package:firebase_auht_client/models/authModel.dart';
import 'package:firebase_auht_client/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _splashScreen();
        }
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
                return _splashScreen();
              }
              return _loginPage(context);
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
                      builder: (_context) => EmailPage())),
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
}

class EmailPage extends StatefulWidget {
  const EmailPage({
    Key? key,
  }) : super(key: key);

  @override
  _EmailPageState createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthModel>(
      create: (_) => AuthModel(),
      builder: (context, _) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  text: 'Log in',
                ),
                Tab(
                  text: 'Sign Up',
                )
              ],
            ),
          ),
          body: TabBarView(children: [
            _loginPage(context),
            _signUpPage(context),
          ]),
        ),
      ),
    );
  }

  _signUpPage(context) {
    final GlobalKey<FormFieldState> _passwordKey = GlobalKey();
    final GlobalKey<FormFieldState> _rePasswordKey = GlobalKey();
    final GlobalKey<FormFieldState> _emailKey = GlobalKey();
    return Center(
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
            TextFormField(
              autofocus: false,
              key: _rePasswordKey,
              decoration: InputDecoration(labelText: 'password'),
              validator: (str) {
                if (_passwordKey.currentState != null &&
                    str != _passwordKey.currentState!.value &&
                    _passwordKey.currentState!.isValid) {
                  return 'Password dont match';
                }
              },
            ),
            ElevatedButton.icon(
                onPressed: () async {
                  if (_passwordKey.currentState!.validate() &&
                      _rePasswordKey.currentState!.validate()) {
                    await Provider.of<AuthModel>(context, listen: false)
                        .handleEmailRegister(context,
                            email: _emailKey.currentState!.value,
                            password: _passwordKey.currentState!.value);
                  }
                },
                icon: Icon(Icons.email),
                label: Text('Sign Up'))
          ],
        ),
      ),
    );
  }

  _loginPage(context) {
    final GlobalKey<FormFieldState> _passwordKey = GlobalKey();
    final GlobalKey<FormFieldState> _emailKey = GlobalKey();
    return Center(
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
                    await Provider.of<AuthModel>(context, listen: false).handleEmailSignIn(context,
                    email: _emailKey.currentState!.value,
                    password: _passwordKey.currentState!.value
                    );
                  }
                },
                icon: Icon(Icons.email),
                label: Text('Log in')),
            Padding(
                padding: EdgeInsets.all(10),
                child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => _resetPassword())),
                    icon: Icon(Icons.password),
                    label: Text("Forgot Password")))
          ],
        ),
      ),
    );
  }

  Widget _resetPassword() {
    GlobalKey<FormFieldState> _emailKey = GlobalKey();
    return ChangeNotifierProvider(
      create: (_) => AuthModel(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text('Reset Password'),
        ),
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
                ElevatedButton.icon(
                    onPressed: () async {
                      _emailKey.currentState != null
                          ? await Provider.of<AuthModel>(context, listen: false)
                              .handleResetPassword(context,
                                  email: _emailKey.currentState!.value)
                          : null;
                    },
                    icon: Icon(Icons.email),
                    label: Text('reset password'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
