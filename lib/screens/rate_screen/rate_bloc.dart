import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart';
import 'package:flutter_test_app/screens/login_screen/login_bloc.dart';
import 'package:rxdart/rxdart.dart';

class RateBloc implements BlocBase{
  static const RATING_DELIMITER = " - ";
  Item ratedRestaurant;
  BehaviorSubject<List<Item>> ratedRestaurants;
  int ratedRestaurantIndex = 0;
  int ratedRestaurantsLength = 1;
  RateBloc(this.ratedRestaurant){
    ratedRestaurants = new BehaviorSubject();
  }

  @override
  void dispose() {
    ratedRestaurants.close();

  }

  saveRating(Item restaurant, BuildContext context) async{
    QuerySnapshot userReferences = await Firestore.instance.collection("Rated").where("id", isEqualTo: LoginBloc.restaurantRatedID).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    var ratedRestaurantsSnapshot = Firestore.instance.collection("Rated").document("$userRef");
    var step = 100 / (ratedRestaurantsLength - 1);
    ratedRestaurantsSnapshot.updateData(
      {
        "ratedRest" : FieldValue.arrayRemove(
            [
              {
                "restaurantId"      : restaurant.id,
                "restaurantTitle"   : restaurant.title,
                "restaurantVicinity": restaurant.vicinity,
                "restaurantRating"  : restaurant.totalRating
              }
            ]
        )
      }
    );
    var newRating = "${(step * (ratedRestaurantsLength - ratedRestaurantIndex - 1)).toString()}$RATING_DELIMITER ${restaurant.totalRating}";
    ratedRestaurantsSnapshot.updateData(
      {
        "ratedRest" : FieldValue.arrayUnion(
          [
            {
              "restaurantId"       :restaurant.id,
              "restaurantTitle"    : restaurant.title,
              "restaurantVicinity" : restaurant.vicinity,
              "restaurantRating"   : ratedRestaurantsLength == 1 ? "" : newRating
            }
          ]
        )
      }
    );
    var onlyOneRestaurant = ratedRestaurantsLength == 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          title: Text("Thanks${onlyOneRestaurant ? ", please pick another place to rate":""}"),
          content: onlyOneRestaurant? Column(mainAxisSize: MainAxisSize.min):Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("YOUR RATING: 65"),
              Text("BEFORE: 78"),
              Text("AFTER: 75"),

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
    QuerySnapshot userReferences = await Firestore.instance.collection("Rated").where("id", isEqualTo: LoginBloc.restaurantRatedID).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    var ratedRestaurantsSnapshot = await Firestore.instance.collection("Rated").document("$userRef").get();
    var previousRatedRest = ratedRestaurantsSnapshot.data["ratedRest"] ?? [];
    var rests = List<Item>();
    (previousRatedRest as List).forEach((element){
      String rating = element['restaurantRating'];
      var ratingArray = rating.split(RateBloc.RATING_DELIMITER);
      double totalRating = 0;
      ratingArray.forEach((rate){
        if(rate != " " && rate != ""){
          totalRating += (1/(ratingArray.length - 1)) * double.parse(rate);
        }
      });
      rests.add(
        Item(
          title: element['restaurantTitle'],
          id: element['restaurantId'],
          vicinity: element['restaurantVicinity'],
          averageRating: element['restaurantRating'],
          totalRating: totalRating.toString()
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