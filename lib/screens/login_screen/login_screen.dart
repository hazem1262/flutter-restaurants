import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/base_widget.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/login_screen/login_bloc.dart';
import 'package:flutter_test_app/screens/splash_screen/splash_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyInheritedWidget(child: BasePageWrapper(child: LoginScreenBloc()),);
  }
}
class LoginScreenBloc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: LoginBloc(),
      child: ActualLoginScreen(),
    );
  }
}

class ActualLoginScreen extends StatefulWidget {
  @override
  _ActualLoginScreenState createState() => _ActualLoginScreenState();
}

class _ActualLoginScreenState extends State<ActualLoginScreen> {
  double _width = 220.0;
  bool _showText = true;
  LoginBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        exit(0);
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 100,),
              Hero(
                  tag: SplashScreen.LOGO_TAG,
                  child: FlutterLogo(size: 140,)
              ),
              SizedBox(height: 20,),
              Hero(
                tag: SplashScreen.TITLE_TAG,
                child: Material(
                  color: Colors.transparent,
                  child: Text("Flutter test app",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                    ),),
                ),
              ),
              SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.only(left: 70, right: 70),
                child: TextField(
                  controller: _bloc.controller,
                  decoration: InputDecoration(
                    labelText: "user name",
                    contentPadding: EdgeInsets.all(8),
                  ),

                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(left: 70, right: 70),
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      width: _width,
                      height: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(
                              color: Colors.blue,
                              width: 1,
                              style: BorderStyle.solid
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Center(
                          child: Stack(
                            children: <Widget>[
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _showText ? 1:0,
                                child: Center(child: Text("Login", style: TextStyle(color: Colors.blue),))
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: !_showText ? 1:0,
                                child: Center(child: CircularProgressIndicator()),
                              )
                            ],
                          )
                      ),
                    ),
                  ),
                ),
                onTap: (){
                  if(_bloc.controller.text.isNotEmpty){
                    setState(() {
                      _width = 60;
                      _showText = false;
                    });
                    _bloc.loginOrSignUpUser(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
