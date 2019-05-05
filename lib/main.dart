import 'package:flutter/material.dart';
import 'package:flutter_test_app/screens/home_screen/home_screen.dart';
import 'package:flutter_test_app/screens/login_screen/login_screen.dart';
import 'package:flutter_test_app/screens/splash_screen/splash_screen.dart';
import 'package:flutter_test_app/utility/resources.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      initialRoute: ScreenRoutes.SPLASH_SCREEN,
      onGenerateRoute: _getRoute,
    );
  }
}
Route _getRoute(RouteSettings settings){
  switch(settings.name){
    case ScreenRoutes.SPLASH_SCREEN:
      return _buildRoute(settings, SplashScreen());
    case ScreenRoutes.LOGIN_SCREEN:
      return _buildRoute(settings, LoginScreen(), customTransitionsBuilder: bottomUpTransition, transitionDuration: 800);
    case ScreenRoutes.HOME_SCREEN:
      return _buildRoute(settings, HomeScreen(userName: (settings.arguments as List<String>)[0], userId: (settings.arguments as List<String>)[1],));
    default:
      return null;
  }
}
PageRouteBuilder _buildRoute(RouteSettings settings, Widget page, {int transitionDuration = 400, RouteTransitionsBuilder customTransitionsBuilder }){
  return PageRouteBuilder(
      settings: settings,
      transitionDuration: Duration(milliseconds: transitionDuration),
      pageBuilder: (BuildContext context, _, __) => page,
      transitionsBuilder: customTransitionsBuilder == null ? (_, Animation<double> animation, Animation<double> secondaryAnimation, Widget child){
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      }: customTransitionsBuilder
  );
}

// handle bottom to up animation
RouteTransitionsBuilder bottomUpTransition = (_, Animation<double> animation, Animation<double> secondaryAnimation, Widget child){
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: _kBottomUpTween.animate(animation),
      child: child,
    ),
  );
};
// Offset from offscreen bottom to fully on screen.
final Tween<Offset> _kBottomUpTween = new Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);