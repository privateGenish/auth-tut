import 'dart:io';

import 'package:firebase_auht_client/models/authModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
        builder: (context, pref) {
          if (pref.hasData) {
            return FutureBuilder<dynamic>(
                future: _getUserData(auth.currentUser!.uid, pref.data!.getString('Access-Token')),
                builder: (context, httpSnapshot) {
                  if (httpSnapshot.hasData &&
                      httpSnapshot.data!.statusCode == 200) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(httpSnapshot.data!.body.toString()),
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
                  if (httpSnapshot.connectionState == ConnectionState.done) {
                    return _errorScreen();
                  }
                  return _splashScreen();
                });
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

  Widget _errorScreen() => Scaffold(
          // color: Colors.red.withOpacity(0.2),
          body: Center(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterLogo(
            size: 48,
          ),
          Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text("Sorry an error have been occurred"))
        ],
      )));

  _getUserData(uid, token) async {
    print(token);
    var client = http.Client();
    Uri uri = await Uri.parse('http://192.168.1.103:3000/user/$uid');
    http.Response res = await client
        .get(uri, headers: {HttpHeaders.authorizationHeader: token});
    return res;
  }
}
