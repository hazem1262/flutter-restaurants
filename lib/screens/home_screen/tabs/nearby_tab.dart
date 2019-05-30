import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/bloc_provider.dart';
import 'package:flutter_test_app/screens/home_screen/home_bloc.dart';
import 'package:flutter_test_app/screens/home_screen/restaurants_data.dart';
import 'package:flutter_test_app/utility/resources.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
class NearByTab extends StatefulWidget {
  @override
  _NearByTabState createState() => _NearByTabState();
}


class _NearByTabState extends State<NearByTab> with AutomaticKeepAliveClientMixin {
  HomeBloc _bloc;
  final ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: _bloc.nearByRestaurants,
      builder: (buildContext, snapshot){
        if(snapshot.hasData){
          var restaurants = snapshot.data;
          var reachBottom = true;
          return NotificationListener(
            onNotification: (ScrollNotification notification){
              if (notification is ScrollUpdateNotification){
                if(scrollController.position.maxScrollExtent > scrollController.offset &&
                    scrollController.position.maxScrollExtent - scrollController.offset <=
                        50 &&
                    scrollController.position.axisDirection == AxisDirection.down && reachBottom){
                  _bloc.fetchRestaurants();
                  reachBottom = false;
                }
              }
            },
            child: ListView.builder(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(15),
              itemCount: _bloc.nextPage == null ? restaurants.length : restaurants.length + 1,
              itemBuilder: (buildContext, index){
                // display loading if there is more pages to be loaded
                if(_bloc.nextPage != null && index == restaurants.length ){
                  return Center(child: CircularProgressIndicator());
                }
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
                          child: ActionChip(
                            backgroundColor: Colors.blue,
                            onPressed: (){
//                              _bloc.saveRestaurant(restaurants[index]);
                              Navigator.pushNamed(context, ScreenRoutes.RATE_SCREEN, arguments: [restaurants[index], _bloc.userId]);
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
            ),
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
}
