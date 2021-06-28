import 'package:firebase_auht_client/models/authModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(snapshot.data!.getString('Access-Token')!),
                ),
                TextButton.icon(
                    onPressed: () =>
                        Provider.of<AuthModel>(context, listen: false)
                            .handleSignOut(),
                    icon: Icon(Icons.logout),
                    label: Text("Log Out")),
                Padding(padding: EdgeInsets.all(10.0)),
                TextButton.icon(
                    onPressed: () =>
                        Provider.of<AuthModel>(context, listen: false)
                            .handleDeleteUser(context),
                    icon: Icon(Icons.delete),
                    label: Text('Delete User'))
              ],
            );
          }
          return _splashScreen();
        });
  }

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
