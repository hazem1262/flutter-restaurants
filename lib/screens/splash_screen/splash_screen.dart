import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/utility/resources.dart';

class SplashScreen extends StatefulWidget {
  static const LOGO_TAG = 'logoTag';
  static const TITLE_TAG = 'titleTag';
  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }

}

class _SplashScreenState extends State<SplashScreen> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: 1500), (){
      Navigator.pushNamed(context, ScreenRoutes.LOGIN_SCREEN);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Hero(
              tag: SplashScreen.LOGO_TAG,
              child: FlutterLogo(size: 240,)
          ),
          Hero(
            tag: SplashScreen.TITLE_TAG,
            child: Material(
              color: Colors.transparent,
              child: Text("Flutter test app",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
