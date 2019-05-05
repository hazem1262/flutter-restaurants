import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/utility/resources.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc implements BlocBase{
  static const String lastUserPrefs = "lastUserPrefs";
  TextEditingController controller;
  FirebaseAuth _auth;
  LoginBloc(){
    _auth = FirebaseAuth.instance;
    controller = TextEditingController();
    _getLatLoggedUser();
  }
  _getLatLoggedUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastLoggedUser = prefs.getString(lastUserPrefs) ?? "";
    controller.text = lastLoggedUser;
  }
  void loginOrSignUpUser(BuildContext context) async{
    final userEmail = _getFormattedEmail(controller.text);
    final password = "12345678";
    // save last user to shared prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(lastUserPrefs, controller.text);
    await _auth
        .signInWithEmailAndPassword(email: userEmail, password: password).then((signedUser)async{
      var location = new Location();
      var locationPermission = await location.requestPermission();
      if(locationPermission){
        Navigator.pushNamed(context, ScreenRoutes.HOME_SCREEN, arguments: [controller.text, signedUser.uid]);
      }

    })
        .catchError((error)async{
      await _registerUser(userEmail, password).then((newUser)async{
        var location = new Location();
        var locationPermission = await location.requestPermission();
        if(locationPermission){
          Navigator.pushNamed(context, ScreenRoutes.HOME_SCREEN, arguments: [controller.text, newUser.uid]);
        }
      });
    });
  }

  String _getFormattedEmail(String unFormattedEmail) {
    return "${unFormattedEmail.replaceAll(" ", "1qwesda3")}@yahoo.com";
  }

  Future<FirebaseUser> _registerUser(String userEmail, String password) async{
    final FirebaseUser user = await _auth.createUserWithEmailAndPassword(
      email: userEmail,
      password: password,
    );
    print(user);
    CollectionReference dbUsers = Firestore.instance.collection("users");
    Firestore.instance.runTransaction((transaction)async{
      dbUsers.add({"id": user.uid});
    });
    return user;
  }

  @override
  void dispose() {

  }

}