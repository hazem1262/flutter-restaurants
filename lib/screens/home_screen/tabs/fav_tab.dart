import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/home_bloc.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
class FavTab extends StatefulWidget {
  final String userId;

  const FavTab({Key key, this.userId}) : super(key: key);
  @override
  _FavTabState createState() => _FavTabState();
}


class _FavTabState extends State<FavTab> with AutomaticKeepAliveClientMixin {
  HomeBloc _bloc;
  Stream<DocumentSnapshot > favRestaurantsSnapshot;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<HomeBloc>(context);
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
    return StreamBuilder<DocumentSnapshot>(
      stream: favRestaurantsSnapshot,
      builder: (buildContext, snapshot){
        if(snapshot.hasData){
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(15),
            itemCount: (snapshot.data["favRest"] ?? []).length,
            itemBuilder: (buildContext, index){
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
                                (snapshot.data.data["favRest"][index])["restaurantTitle"],
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            HtmlWidget(
                                (snapshot.data.data["favRest"][index])["restaurantVicinity"]
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ActionChip(
                          backgroundColor: Colors.blue,
                          onPressed: (){
                            _bloc.removeFromSaved(
                                Item(
                                    title: (snapshot.data.data["favRest"][index])["restaurantTitle"],
                                    id: (snapshot.data.data["favRest"][index])["restaurantId"],
                                    vicinity: (snapshot.data.data["favRest"][index])["restaurantVicinity"]
                                )
                            );
                          },
                          label: Text("Remove", style: TextStyle(
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
            child: Text("You Have No Saved Data!"),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
