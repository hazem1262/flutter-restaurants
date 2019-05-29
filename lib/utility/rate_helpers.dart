import 'package:flutter_test_app/screens/rate_screen/rate_bloc.dart';

String calcRate(String rating){
  var ratingArray = rating.split(RateBloc.RATING_DELIMITER);
  ratingArray.remove("");
  ratingArray.remove(" ");
  double totalRating = 0;
  ratingArray.forEach((rate){
    if(rate != " " && rate != ""){
      totalRating += (1/(ratingArray.length )) * double.parse(rate);
    }
  });
  totalRating = totalRating == 0 ? 1 : totalRating;
  return totalRating.round().toString();
}