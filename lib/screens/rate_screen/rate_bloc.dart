import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart';
import 'package:flutter_test_app/screens/login_screen/login_bloc.dart';
import 'package:flutter_test_app/utility/api_consts.dart';
import 'package:flutter_test_app/utility/rate_helpers.dart';
import 'package:rxdart/rxdart.dart';

class RateBloc implements BlocBase{
  static const RATING_DELIMITER = " - ";
  Item ratedRestaurant;
  final String userId;
  BehaviorSubject<List<Item>> ratedRestaurants;
  int ratedRestaurantIndex = 0;
  int ratedRestaurantsLength = 1;
  RateBloc(this.ratedRestaurant, this.userId){
    ratedRestaurants = new BehaviorSubject();
  }

  @override
  void dispose() {
    ratedRestaurants.close();

  }

  saveRating(Item restaurant, BuildContext context) async{
    QuerySnapshot userReferences = await Firestore.instance.collection(FireBaseConst.userCollection).where("id", isEqualTo: userId).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    var ratedRestaurantsSnapshot = Firestore.instance.collection(FireBaseConst.userCollection).document("$userRef");
    var step = 100 / (ratedRestaurantsLength - 1);
    ratedRestaurantsSnapshot.updateData(
      {
        FireBaseConst.ratedDocument : FieldValue.arrayRemove(
            [
              {
                "restaurantId"      : restaurant.id,
                "restaurantTitle"   : restaurant.title,
                "restaurantVicinity": restaurant.vicinity,
                "restaurantRating"  : restaurant.firebaseRating
              }
            ]
        )
      }
    );
    var newRating = "${(step * (ratedRestaurantsLength - ratedRestaurantIndex - 1)).toString()}$RATING_DELIMITER ${restaurant.firebaseRating}";
    ratedRestaurantsSnapshot.updateData(
      {
        FireBaseConst.ratedDocument : FieldValue.arrayUnion(
          [
            {
              "restaurantId"       : restaurant.id,
              "restaurantTitle"    : restaurant.title,
              "restaurantVicinity" : restaurant.vicinity,
              "restaurantRating"   : ratedRestaurantsLength == 1 ? "" : newRating
            }
          ]
        )
      }
    );
    var onlyOneRestaurant = ratedRestaurantsLength == 1;
    var yourRate = onlyOneRestaurant ? 0 : (step * (ratedRestaurantsLength - ratedRestaurantIndex - 1)).round();
    yourRate = yourRate == 0 ? 1 : yourRate;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          title: Text("Thanks${onlyOneRestaurant ? ", please pick another place to rate":""}"),
          content: onlyOneRestaurant? Column(mainAxisSize: MainAxisSize.min):Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("YOUR RATING: $yourRate"),
              Text("BEFORE: ${calcRate(restaurant.totalRating)}"),
              Text("AFTER: ${calcRate(newRating)}"),

            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  void initRatedRestaurants(BuildContext context) async {
    QuerySnapshot userReferences = await Firestore.instance.collection(FireBaseConst.userCollection).where("id", isEqualTo: userId).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    var ratedRestaurantsSnapshot = await Firestore.instance.collection(FireBaseConst.userCollection).document("$userRef").get();
    var previousRatedRest = ratedRestaurantsSnapshot.data[FireBaseConst.ratedDocument] ?? [];
    var rests = List<Item>();
    (previousRatedRest as List).forEach((element){
      String rating = element['restaurantRating'];
      rests.add(
        Item(
          title          : element['restaurantTitle'],
          id             : element['restaurantId'],
          vicinity       : element['restaurantVicinity'],
          firebaseRating : element['restaurantRating'],
          totalRating    : calcRating(rating)
        )
      );
    });
    var ratedR = rests.firstWhere((restaurant){
      return restaurant.id == ratedRestaurant.id;
    }, orElse: (){
      return null;
    });
    rests.sort((a, b) => a.compareTo(b));
    if(ratedR != null){
      ratedR.tobeRated = true;
      ratedRestaurantIndex = rests.indexOf(ratedR);
    }else{
      ratedRestaurant.tobeRated = true;
      rests.insert((rests.length/2).round(), ratedRestaurant);
      ratedRestaurantIndex = rests.indexOf(ratedRestaurant);
    }

    ratedRestaurants.add(rests);
    ratedRestaurantsLength = rests.length;
    if(ratedRestaurantsLength == 1){
      saveRating(ratedRestaurant, context);
    }
  }


}