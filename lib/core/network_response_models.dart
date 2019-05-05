class DataResource<T> {

  T data;
  AppError error;

}
/// Custom Exception Handling: https://www.youtube.com/watch?v=tI252cev-Ec
/// Factory Constructors in Dart: https://www.youtube.com/watch?v=ZCmSRqhgyps
/// This is a base error class
/// This Exception handler is responsible for creating an error corresponding to the received error code
class AppError implements Exception{

  AppError._();
  String errorMessage;
  String errorName;

  factory AppError(int errorCode, Map<String,dynamic> errorBody){
    switch (errorCode) {
      case 401:
        return new UnAuthorizedUser(errorBody);
      default:
        return new SolError(errorBody);
    }
  }
}

class UnAuthorizedUser extends AppError {
  UnAuthorizedUser(Map<String, dynamic> errorBody) : super._() {
    errorMessage = errorBody['message'];
    errorName = errorBody['error'];
  }
}

class SolError extends AppError {
  SolError(Map<String, dynamic> errorBody): super._(){
    errorMessage = errorBody['message'];
    errorName = errorBody['error'];
  }
}


