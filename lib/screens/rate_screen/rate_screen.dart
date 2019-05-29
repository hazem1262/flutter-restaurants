import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/base_widget.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart';
import 'package:flutter_test_app/screens/rate_screen/rate_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class RateScreen extends StatelessWidget {
  final Item ratedRestaurant;

  const RateScreen({Key key, this.ratedRestaurant}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MyInheritedWidget(
      child: BasePageWrapper(child: RateScreenBloc(ratedRestaurant: ratedRestaurant,),),
    );
  }
}

class RateScreenBloc extends StatelessWidget {
  final Item ratedRestaurant;

  const RateScreenBloc({Key key, this.ratedRestaurant}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: RateBloc(ratedRestaurant),
      child: ActualRateScreen(),
    );
  }
}
class ActualRateScreen extends StatefulWidget {
  @override
  _ActualRateScreenState createState() => _ActualRateScreenState();
}

class _ActualRateScreenState extends State<ActualRateScreen> {
  RateBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<RateBloc>(context);
    _bloc.initRatedRestaurants(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<List<Item>>(
          stream: _bloc.ratedRestaurants,
          builder: (buildContext, snapshot){
            var restaurants = snapshot.data;
            if(snapshot.hasData){
              return ReorderableListView(
                header: Text("the best on top, by quality, not price",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(15),
                children: restaurants.map((restaurant){
                  return buildCard(restaurant);
                }).toList(),
                onReorder: (oldOrder, newOrder){
                  print("old order is: $oldOrder, new order is: $newOrder");
                  setState(() {
                    Item oldItem = restaurants.removeAt(oldOrder);
                    if(oldOrder > newOrder){
                      restaurants.insert(newOrder, oldItem);
                      _bloc.ratedRestaurantIndex = newOrder;
                    }else if(newOrder > oldOrder){
                      restaurants.insert(newOrder - 1, oldItem);
                      _bloc.ratedRestaurantIndex = newOrder - 1;

                    }

                  });
                }
              );
            }else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildCard(Item restaurant) {
    if(restaurant.tobeRated){
      return buildRestaurantWidget(restaurant);
    }
    return GestureDetector(
      child: buildRestaurantWidget(restaurant),
      key: Key(restaurant.title),
      onLongPress: (){
        print("item long pressed");
      },
    );
  }

  Widget buildRestaurantWidget(Item restaurant){
    return Card(
      key: Key(restaurant.title),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom:8.0),
                    child: Text(
                      restaurant.title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  HtmlWidget(
                      restaurant.vicinity
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: restaurant.tobeRated ? ActionChip(
                backgroundColor: Colors.blue,
                onPressed: (){
                  _bloc.saveRating(restaurant, context);
                },
                label: Text("save rating", style: TextStyle(
                    color: Colors.white
                ),),
              ): Container(),
            )
          ],
        ),
      ),
    );
  }
}
