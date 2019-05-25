import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart';
import 'package:flutter_test_app/screens/login_screen/login_bloc.dart';
import 'package:rxdart/rxdart.dart';

class RateBloc implements BlocBase{
  Item ratedRestaurant;
  BehaviorSubject<List<Item>> ratedRestaurants;

  RateBloc(this.ratedRestaurant){
    ratedRestaurants = new BehaviorSubject();
    initRatedRestaurants();
  }

  @override
  void dispose() {
    ratedRestaurants.close();

  }

  saveRating(Item restaurant) async{
    QuerySnapshot userReferences = await Firestore.instance.collection("Rated").where("id", isEqualTo: LoginBloc.restaurantRatedID).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    var ratedRestaurantsSnapshot = Firestore.instance.collection("Rated").document("$userRef");
    ratedRestaurantsSnapshot.updateData(
      {
        "ratedRest" : FieldValue.arrayUnion(
          [
            {
              "restaurantId":restaurant.id,
              "restaurantTitle": restaurant.title,
              "restaurantVicinity": restaurant.vicinity
            }
          ]
        )
      }
    );

  }

  void initRatedRestaurants() async{
    QuerySnapshot userReferences = await Firestore.instance.collection("Rated").where("id", isEqualTo: LoginBloc.restaurantRatedID).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    var ratedRestaurantsSnapshot = await Firestore.instance.collection("Rated").document("$userRef").get();
    var previousRatedRest = ratedRestaurantsSnapshot.data["ratedRest"] ?? [];
    var rests = List<Item>();
    (previousRatedRest as List).forEach((element){
      rests.add(
        Item(
          title: element['restaurantTitle'],
          id: element['restaurantId'],
          vicinity: element['restaurantVicinity']
        )
      );
    });
    ratedRestaurant.tobeRated = true;
    rests.add(ratedRestaurant);
    ratedRestaurants.add(rests);
  }

}