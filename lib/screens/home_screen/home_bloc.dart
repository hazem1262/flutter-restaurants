import 'dart:convert';

import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const APP_ID = "MTCOZFZANbnfGaLArr8q";
const APP_CODE = "cUHtSdnS3BJyKm6Kluum_Q";
class HomeBloc implements BlocBase{

  final String userId;
  List<Item> nearByList;
  String nextPage ;
  Stream<DocumentSnapshot> favRestaurantsFireBase;
  HomeBloc(this.userId){
    nearByRestaurants = new BehaviorSubject();
    favRestaurants = new BehaviorSubject();
    nearByList = new List();
  }
  BehaviorSubject<List<Item>> nearByRestaurants;
  BehaviorSubject<List<Item>> favRestaurants;

  Observable<List<Item>> get nearByRestaurantsObservable => nearByRestaurants.stream;
  Observable<List<Item>> get favRestaurantsObservable => favRestaurants.stream;
  @override
  void dispose() {
    nearByRestaurants.close();
    favRestaurants.close();
  }

  saveRestaurant(Item restaurant)async{
//    nearByList.remove(restaurant);
    restaurant.isFav = true;
    nearByRestaurants.add(nearByList.where((item){return item.isFav == false;}).toList());
    QuerySnapshot userReferences = await Firestore.instance.collection("users").where("id", isEqualTo: userId).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    final favRestaurantsRef = Firestore.instance.collection("users").document("$userRef");//yrdgfd
    favRestaurantsRef.updateData({"favRest": FieldValue.arrayUnion(
      [
          {
            "restaurantId":restaurant.id,
            "restaurantTitle": restaurant.title,
            "restaurantVicinity": restaurant.vicinity
          }
      ]
    )});

  }

  removeFromSaved(Item restaurant)async{
//    remove from nearby restaurants
    final favRestaurant = nearByList.firstWhere((rest) => rest.id == restaurant.id, orElse: (){});
    if(favRestaurant != null){
      favRestaurant.isFav = false;
    }
    nearByRestaurants.add(nearByList.where((item){return item.isFav == false;}).toList());

    // get reference to the user document
    QuerySnapshot userReferences = await Firestore.instance.collection("users").where("id", isEqualTo: userId).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    final favRestaurantsRef = Firestore.instance.collection("users").document("$userRef");

    // remove this restaurant from fav restaurants list
    favRestaurantsRef.updateData({"favRest": FieldValue.arrayRemove(
        [
          {
            "restaurantId":restaurant.id,
            "restaurantTitle": restaurant.title,
            "restaurantVicinity": restaurant.vicinity
          }
        ]
    )});
  }

  // get restaurants according to user is current position
  fetchRestaurants({LocationData  currentLocation}) async{
    String endPoint; //37.7896,-122.40745;r=1000.0
    if(currentLocation != null){
      endPoint = "https://places.api.here.com/places/v1/browse?app_id=$APP_ID&app_code=$APP_CODE&at=${currentLocation.latitude},${currentLocation.longitude}&cat=eat-drink";
    }else{
      endPoint = nextPage;
    }
    //get all restaurants
    final response = await Client().get(endPoint);

    if(currentLocation != null){
      print("response is: " + response.body);
      nearByList.addAll(restaurantsFromJson(response.body).results.items);
      nextPage = restaurantsFromJson(response.body).results.next;

    }else{
      print("next page response is: " + response.body);
      nearByList.addAll(Results.fromJson(json.decode(response.body)).items);
      nextPage = Results.fromJson(json.decode(response.body)).next;
    }
    // get fav list to remove from near by list
    QuerySnapshot userReferences = await Firestore.instance.collection("users").where("id", isEqualTo: userId).getDocuments();
    final userRef = userReferences.documents[0].documentID;
    DocumentSnapshot favRestaurants = await Firestore.instance.collection("users").document("$userRef").get();
    final restData = favRestaurants.data["favRest"] as List<dynamic> ?? [];
    for(final rest in restData){
      final favRestaurant = nearByList.firstWhere((restaurant) => restaurant.id == rest["restaurantId"], orElse: (){});
      if(favRestaurant != null){
        favRestaurant.isFav = true;
      }
      // remove fav restaurants from nearby list
//      nearByList.removeWhere((restaurant) => restaurant.id == rest["restaurantId"]);

    }
    nearByRestaurants.add(nearByList.where((item){return item.isFav == false;}).toList());
  }
}