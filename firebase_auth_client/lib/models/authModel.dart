import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthModel with ChangeNotifier {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  FirebaseAuth _auth = FirebaseAuth.instance;

  get auth => _auth;

  handleGoogleSilentSignIn() async {
    await _googleSignIn.signInSilently().then((googleUser) async {
      final pref = await SharedPreferences.getInstance();

      // Trigger the authentication flow

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      FirebaseAuth.instance.currentUser!.reload();

      pref.setString('Auth-Method', 'GOOGLE');
    });
  }

  handleGoogleSignIn() async {
    final pref = await SharedPreferences.getInstance();

    // Trigger the authentication flow
    await _googleSignIn.signIn().then((googleUser) async {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      FirebaseAuth.instance.currentUser!.reload();

      pref.setString('Auth-Method', 'GOOGLE');
    }).catchError((e) => print("error: $e"));
  }

  handleSignOut() async {
    final pref = await SharedPreferences.getInstance();

    if (pref.getString('Auth-Method') == 'GOOGLE') {
      print('GOOGLE sign out');
      await _googleSignIn.signOut();
    }

    await auth.signOut();
  }
}
