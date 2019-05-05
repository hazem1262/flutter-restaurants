import 'dart:convert';
import 'package:flutter_test_app/core/network_response_models.dart';
import 'package:flutter_test_app/utility/api_consts.dart';
import 'package:http/http.dart' show Client;

class HttpClient{
  final _client = Client();
  static final HttpClient _singleton = new HttpClient._internal();

  factory HttpClient() {
    return _singleton;
  }
  HttpClient._internal();

  get(String endPoint, {Map<String, String> params , String path}) async{
    if(params == null){
      params = Map();
    }
    final response = await _client.get(_getUrl(endPoint, params:params, path:path),
    headers: await _getHeaders());
    print("$endPoint : ${response.body}");
    if (response.statusCode == 200){
      // If the call to the server was successful, parse the JSON
      return Future<String>.value(response.body);
    }else {
      // If that call was not successful, throw an error.
      return Future<String>.error(AppError(response.statusCode, json.decode(response.body)));
    }

  }

  post(String endPoint, body) async {
    print("$endPoint : $body");
    final response = await _client.post(
        _getUrl(endPoint),
        headers: await _getHeaders(),
        body: body);
    print("$endPoint : ${response.body}");
    // wrapper object for response from the network, wraps data and error
    if (response.statusCode == 200) {
      // If the call to the server was successful, pass the body
      return Future<String>.value(response.body);
    } else {
    // If that call was not successful, throw an error.
    return Future<String>.error(AppError(response.statusCode, json.decode(response.body)));
    }
  }

  _getUrl(String endPoint, {Map<String, String> params, String path}) {
    String requestPath;
    if(path != null && path.isNotEmpty){
      requestPath = endPoint + "/$path";
    }else{
      requestPath = endPoint;
    }
    return Uri(
      scheme: ApiConfigs.schema,
      host: ApiConfigs.host,
      path: requestPath,
      queryParameters: params
    );
  }

  _getHeaders() {
    return <String, String>{
      ApiHeaders.contentType: ApiHeaders.contentTypeValue
    };
  }


}