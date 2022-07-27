import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/helperServices/sharedPreferenceHelper.dart';
import 'package:flutter_application_1/mainPage.dart';
import 'package:flutter_application_1/sevices/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return auth.currentUser;
  }

  Future signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential authCredential = await GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential result =
        await _firebaseAuth.signInWithCredential(authCredential);

    User userDeatail = result.user!;

    if (result != null) {
      SharedPreferenceHelper().saveUserEmail(userDeatail.email!);
      SharedPreferenceHelper().saveUserId(userDeatail.uid);
      SharedPreferenceHelper().saveDisplayName(userDeatail.displayName!);
      SharedPreferenceHelper().saveUserProfileUrl(userDeatail.photoURL!);

      Map<String, dynamic> userInfoMap = {
        "email": userDeatail.email,
        "name": userDeatail.displayName,
        "username": userDeatail.email?.replaceAll("@gmail.com", ""),
        "imageURL": userDeatail.photoURL
      };

      DataBaseMethod()
          .addUserInfoToDB(userDeatail.uid, userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      });
    }
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    auth.signOut();
    preferences.clear();
  }
}
