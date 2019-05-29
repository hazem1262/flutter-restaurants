import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/home_bloc.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart';
import 'package:flutter_test_app/screens/login_screen/login_bloc.dart';
import 'package:flutter_test_app/screens/rate_screen/rate_bloc.dart';
import 'package:flutter_test_app/utility/api_consts.dart';
import 'package:flutter_test_app/utility/rate_helpers.dart';
import 'package:flutter_test_app/utility/resources.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:rxdart/rxdart.dart';
class FavTab extends StatefulWidget {
  final String userId;

  const FavTab({Key key, this.userId}) : super(key: key);
  @override
  _FavTabState createState() => _FavTabState();
}


class _FavTabState extends State<FavTab> with AutomaticKeepAliveClientMixin {
  HomeBloc _bloc;
  Stream<DocumentSnapshot > favRestaurantsSnapshot;
  BehaviorSubject<List<Item>> ratedRestaurants;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<HomeBloc>(context);
    _initFavRestaurants();
    ratedRestaurants = new BehaviorSubject();
  }
  _initFavRestaurants() async{
    QuerySnapshot userReferences = await Firestore.instance.collection("Rated").where("id", isEqualTo: LoginBloc.restaurantRatedID).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    Firestore.instance.collection("Rated").document("$userRef").get().asStream().listen((ratedRestaurantsSnapshot){
      var previousRatedRest = ratedRestaurantsSnapshot.data[FireBaseConst.ratedDocument] ?? [];
      var rests = List<Item>();
      (previousRatedRest as List).forEach((element){
        String rating = element['restaurantRating'];
        var ratingArray = rating.split(RateBloc.RATING_DELIMITER);

        rests.add(
            Item(
                title          : element['restaurantTitle'],
                id             : element['restaurantId'],
                vicinity       : element['restaurantVicinity'],
                firebaseRating : element['restaurantRating'],
                totalRating    : calcRating(rating),
                averageRating  : (ratingArray.length < 3)? "${calcMinPossibleRating(element['restaurantRating'])} - ${calcMaxPossibleRating(element['restaurantRating'])}" : calcRating(rating)
            )
        );
      });

      rests.sort((a, b) => a.compareTo(b));
      ratedRestaurants.add(rests);
    });


  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: ratedRestaurants,
      builder: (buildContext, snapshot){
        var restaurants = snapshot.data;
        if(snapshot.hasData){
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(15),
            itemCount: (restaurants ?? []).length,
            itemBuilder: (buildContext, index){
              if((restaurants ?? []).length == 0){
                return Center(
                  child: Text("There is No Rated Data!"),
                );
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom:8.0),
                              child: Text(
                                (restaurants[index]).title,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            HtmlWidget(
                                (restaurants[index]).vicinity
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text((restaurants[index]).averageRating),
                      ),
                      Expanded(
                        flex: 1,
                        child: ActionChip(
                          backgroundColor: Colors.blue,
                          onPressed: (){
                            Navigator.pushNamed(context, ScreenRoutes.RATE_SCREEN, arguments: restaurants[index]);
                          },
                          label: Text("Rate", style: TextStyle(
                              color: Colors.white
                          ),),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    ratedRestaurants.close();
  }


}
