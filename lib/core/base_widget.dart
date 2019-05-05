import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/network_response_models.dart';
import 'package:connectivity/connectivity.dart';

abstract class BasePage {

  void retryAction();

  void subscribeToStreams();

  void dismissAction();
}

class ErrorHandler {
  final retryAction;
  final dismissAction;
  final AppError error;

  ErrorHandler({
    @required this.error,
    @required this.retryAction,
    @required this.dismissAction
  });

}

class BasePageWrapper extends StatelessWidget {
  final double opacity;
  final Color color;
  final Widget progressIndicator;
  final bool dismissible;
  final Widget child;

  BasePageWrapper({
    Key key,
    this.opacity = 0.3,
    this.color = Colors.grey,
    this.progressIndicator = const LoaderScreen(),
    this.dismissible = true,
    @required this.child,
  })
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyInheritedWidgetState state = MyInheritedWidget.of(context);

    List<Widget> widgetList = [];
    widgetList.add(child);
    Widget overlay;
    bool disableInteraction = true;

    switch (state._screenState) {
      case ScreenStates.LOADING:
        overlay = Center(child: progressIndicator,);
        break;
      case ScreenStates.ERROR:
        overlay = ErrorDialog(
          handler: state._errorHandler,
        );
        break;
      case ScreenStates.OFFLINE:
        overlay = NoNetWorkWidget();
        disableInteraction = false;
        break;
      case ScreenStates.NONE:
        break;
    }

    if (overlay != null ) {
      if (disableInteraction){
        final modal = [
          new Opacity(
            child: new ModalBarrier(dismissible: dismissible, color: color),
            opacity: opacity,
          ),
          overlay
        ];
        widgetList += modal;
      } else {
        widgetList.add(overlay);
      }
    }


    return new Stack(
      children: widgetList,
    );
  }
}


class _MyInherited extends InheritedWidget {
  _MyInherited({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final MyInheritedWidgetState data;

  @override
  bool updateShouldNotify(_MyInherited oldWidget) {
    return true;
  }
}

class MyInheritedWidget extends StatefulWidget {

  final initialState;

  MyInheritedWidget({
    Key key,
    this.child,
    this.initialState
  }) : super(key: key);

  final Widget child;

  @override
  MyInheritedWidgetState createState() => new MyInheritedWidgetState();

  static MyInheritedWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_MyInherited) as _MyInherited)
        .data;
  }
}
class MyInheritedWidgetState extends State<MyInheritedWidget> {

  var _screenState;

  ErrorHandler _errorHandler;

  updateScreenState(ScreenStates value, [ErrorHandler errorHandler]) {
    if (value == ScreenStates.ERROR) {
      assert(errorHandler != null);
      this._errorHandler = errorHandler;
    }
    setState(() {
      _screenState = value;
    });
  }

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        updateScreenState(ScreenStates.OFFLINE);
      } else {
        updateScreenState(widget.initialState);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return new _MyInherited(
      data: this,
      child: widget.child,
    );
  }}

enum ScreenStates {
  LOADING,
  NONE,
  ERROR,
  OFFLINE
}
class NoNetWorkWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
//        color: appTheme.primaryColor,
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: Text("! No Network Available",),
        ),
      ),
    );
  }
}
class LoaderScreen extends StatelessWidget {

  const LoaderScreen({Key key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("In Loading");
    return new CircularProgressIndicator();
  }
}
class ErrorDialog extends StatelessWidget{

  final ErrorHandler handler;

  const ErrorDialog({
    Key key,
    @required
    this.handler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          handler.dismissAction();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color:Colors.black.withOpacity(0.3) ,
          child: Center(
            child: GestureDetector(
              onTap: (){},
              child: buildContainer(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContainer() {
    return Text("error dialog");
  }

}