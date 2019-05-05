import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/base_widget.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/home_bloc.dart';
import 'package:flutter_test_app/screens/home_screen/tabs/fav_tab.dart';
import 'package:flutter_test_app/screens/home_screen/tabs/nearby_tab.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart' hide Location;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String userId;

  const HomeScreen({Key key, this.userName, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MyInheritedWidget(child: BasePageWrapper(child: HomeBlocScreen(userName: userName, userId: userId,),) );
  }
}

class HomeBlocScreen extends StatelessWidget {
  final String userName;
  final String userId;

  HomeBlocScreen({Key key, this.userName, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: HomeBloc(userId),
      child: ActualHomeScreen(userName: userName, userId: userId,),
    );
  }
}

class ActualHomeScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const ActualHomeScreen({Key key, this.userName, this.userId}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ActualHomeScreen> {
  LocationData  currentLocation;
  HomeBloc _bloc;
  Stream<DocumentSnapshot > favRestaurantsSnapshot;
  final ScrollController scrollController = new ScrollController();
  @override
  void initState(){
    super.initState();
    _bloc = BlocProvider.of<HomeBloc>(context);
    getLastKnownLocation();
    _initFavRestaurants();
  }
  _initFavRestaurants() async{
    QuerySnapshot userReferences = await Firestore.instance.collection("users").where("id", isEqualTo: widget.userId).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    setState(() {
      favRestaurantsSnapshot = Firestore.instance.collection("users").document("$userRef").snapshots();
    });
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: (){
          exit(0);
        },
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(widget.userName ),
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(
                    text: "Nearby",
                  ),
                  Tab(
                    text: "Saved",
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                NearByTab(),
                FavTab(userId: widget.userId),
              ],
            )
        ),
      ),
    );
  }

  void getLastKnownLocation() async{
    var location = new Location();
    var locationService = await location.requestService();
    if(locationService){
      // Platform messages may fail, so we use a try/catch PlatformException.
      currentLocation = await location.getLocation();
      _bloc.fetchRestaurants(currentLocation : currentLocation ?? LocationData.fromMap({"latitude": 52.531, "longitude": 13.3843}));
    }

  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }


}

