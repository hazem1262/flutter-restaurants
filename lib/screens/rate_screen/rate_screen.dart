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
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(15),
                itemCount:  restaurants.length,
                itemBuilder: (buildContext, index){
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom:8.0),
                                  child: Text(
                                    restaurants[index].title,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                HtmlWidget(
                                    restaurants[index].vicinity
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: restaurants[index].tobeRated ? ActionChip(
                              backgroundColor: Colors.blue,
                              onPressed: (){
                                _bloc.saveRating(restaurants[index]);
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
                },
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
}
