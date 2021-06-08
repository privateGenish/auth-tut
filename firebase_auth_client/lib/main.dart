import 'package:firebase_auht_client/pages/authPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/initFirebase': (context) => InitFirebase(),
      },
      initialRoute: '/initFirebase',
    );
  }
}

class InitFirebase extends StatefulWidget {
  @override
  _InitFirebaseState createState() => _InitFirebaseState();
}

class _InitFirebaseState extends State<InitFirebase> {
  // initalizing the firebase app
  final Future<FirebaseApp> _initalize = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: _initalize,
        // initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return _errorScreen();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return AuthPage();
          }
          return _splashScreen();
        },
      ),
    );
  }

  Widget _splashScreen() => Material(
        child: Center(
          child: FlutterLogo(),
        ),
      );
  Widget _errorScreen() => Material(
      color: Colors.red.withOpacity(0.2),
      child: Center(
          child: Column(
        children: [
          FlutterLogo(),
          Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text("Sorry an error have been occurred"))
        ],
      )));
}
