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

String calcMinPossibleRating(String rating){
  var ratingArray = rating.split(RateBloc.RATING_DELIMITER);
  ratingArray.remove("");
  ratingArray.remove(" ");
  if(ratingArray.length == 1){
    return (2 * .33 + double.parse(ratingArray[0]) * .33).round().toString();
  }else if(ratingArray.length == 2){
    return (1 * .33 + double.parse(ratingArray[0]) * .33 + double.parse(ratingArray[1]) * .33).round().toString();
  }
  return "";
}

String calcMaxPossibleRating(String rating){
  var ratingArray = rating.split(RateBloc.RATING_DELIMITER);
  ratingArray.remove("");
  ratingArray.remove(" ");
  if(ratingArray.length == 1){
    return (200 * .33 + double.parse(ratingArray[0]) * .33).round().toString();
  }else if(ratingArray.length == 2){
    return (100 * .33 + double.parse(ratingArray[0]) * .33 + double.parse(ratingArray[1]) * .33).round().toString();
  }
  return "";
}

String calcRating(String rating){
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