import 'package:firebase_auht_client/models/authModel.dart';
import 'package:firebase_auht_client/pages/authPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/init': (context) => InitFirebase(),
      },
      initialRoute: '/init',
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthModel>(create: (_) => AuthModel()),
      ],
      builder: (context, child) => Material(
        child: FutureBuilder(
          future: _initalize,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return _errorScreen();
            }
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {

  /// After initalizing the FirebaseApp we may continue to the auth process.
              return AuthPage();
            }
            return _splashScreen();
          },
        ),
      ),
    );
  }

  /// Simple splash screen to present in the time it takes to initalize the firebase app.
  /// Can be replased with any.
  Widget _splashScreen() => Material(
        child: Center(
          child: FlutterLogo(),
        ),
      );

  /// Showing en error to initalize the app.
  ///
  /// Initalizing firebase is crucial for the app to sustain.
  Widget _errorScreen() => Material(
      color: Colors.red.withOpacity(0.2),
      child: Center(
          child: Column(
        children: [
          FlutterLogo(
            size: 48,
          ),
          Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text("Sorry a firebase error have been occurred"))
        ],
      )));
}
