import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthModel with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  get auth => _auth;

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  handleGoogleSilentSignIn(context) async {
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
      await _saveAccessToken();
      FirebaseAuth.instance.currentUser!.reload();

      pref.setString('Auth-Method', 'GOOGLE');
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Google Sign In Failed!")));
      print("Google Sign In Error: $e");
    });
    ;
  }

  handleGoogleSignIn(context) async {
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
      await _saveAccessToken();
      FirebaseAuth.instance.currentUser!.reload();

      pref.setString('Auth-Method', 'GOOGLE');
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Google Sign In Failed!")));
      print("Google Sign In Error: $e");
    });
  }

  FacebookAuth _facebookAuth = FacebookAuth.instance;
  get facebookAuth => _facebookAuth;
  handleFacebookSignIn(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final LoginResult result =
        await _facebookAuth.login(loginBehavior: LoginBehavior.dialogOnly);
    if (result.status == LoginStatus.success) {
      // Create a credential from the access token
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      // Once signed in, return the UserCredential
      try {
        await _auth.signInWithCredential(credential);
        await pref.setString('Auth-Method', 'FACEBOOK');
        await _saveAccessToken();
        await _auth.currentUser!.reload();
      } catch (e) {
        print('Facebook-Firebase Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Facebook Sign In Failed!")));
      }
    } else {
      print('Facebook Login Error: ${result.message}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Facebook Sign In Failed!")));
    }
  }

  handleFacebookSilentLogin(context) async {
    final AccessToken? accessToken = await _facebookAuth.accessToken;
    final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken!.token);
    try {
      final pref = await SharedPreferences.getInstance();
      await _auth.signInWithCredential(credential);
      await pref.setString('Auth-Method', 'FACEBOOK');
      await _saveAccessToken();
      await _auth.currentUser!.reload();
    } catch (e) {
      print('Facebook-Firebase Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Facebook Sign In Failed!")));
    }
  }

  handleEmailSignIn(context, {String? email, String? password}) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(),
                  new Text("Loading"),
                ],
              ),
            )));
    try {
      print('Trying To log in!');
      final pref = await SharedPreferences.getInstance();
      await _auth.signInWithEmailAndPassword(
          email: email!, password: password!);
      await pref.setString('Auth-Method', 'FACEBOOK');
      await _auth.currentUser!.reload();
      Navigator.pop(context);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating, content: Text(e.code)));
      }
      return e.code;
    }
  }

  handleEmailRegister(BuildContext context,
      {String? email, String? password}) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(),
                  new Text("Loading"),
                ],
              ),
            )));
    try {
      final pref = await SharedPreferences.getInstance();
      await _auth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      await pref.setString('Auth-Method', 'NULL');
      print('again!');
      await _auth.currentUser!.reload();
      Navigator.pop(context);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating, content: Text(e.code)));
      }
      return e.code;
    }
  }

  handleSignOut() async {
    final pref = await SharedPreferences.getInstance();

    if (pref.getString('Auth-Method') == 'GOOGLE') {
      print('GOOGLE sign out');
      await _googleSignIn.signOut();
    }
    if (pref.getString('Auth-Method') == 'FACEBOOK') {
      print('GOOGLE sign out');
      await _facebookAuth.logOut();
    }

    await auth
        .signOut()
        .then((value) async => await pref.setString('Auth-Method', 'NULL'));
  }

  _saveAccessToken() async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('Access-Token', await _auth.currentUser!.getIdToken());
  }
}
