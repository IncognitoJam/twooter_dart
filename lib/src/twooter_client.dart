import 'dart:convert';

import 'package:dio/dio.dart';

import 'message.dart';

// The unofficial Twooter client for Dart!
//
// TODO: add features to match official Java client
class TwooterClient {
  static final String _TWOOTER_API_URL = 'http://twooter.johnvidler.co.uk';
  Dio _dio;

  // Creates a new client instance
  TwooterClient() {
    this._dio = Dio();
  }

  // Attempts to determine if the web service is both *online* and *reachable*.
  Future<bool> isUp() async {
    var response = await _query('/');
    return response.statusCode == 200 && response.body == 'OK';
  }

  // Attempt to register a new username.
  Future<String> registerName(String name) async {
    var response = await _query('/registerName', body: {'name': name});
    return response.body;
  }

  Future<HTTPResponse> _query(String path, {Map body}) async {
    var response;

    if (body == null) {
      // make a basic post request when no data is provided
      response = await _dio.post(_TWOOTER_API_URL + path);
    } else {
      // make a post request with json encoded data
      response = await _dio.post(
        _TWOOTER_API_URL + path,
        data: jsonEncode(body),
        options: Options(
          validateStatus: (status) => true,
        ),
      );
    }

    // return relevant data
    // TODO: encode JSON response
    return HTTPResponse(response.statusCode, response.data);
  }
}

class HTTPResponse {
  final int statusCode;
  final dynamic body;

  HTTPResponse(this.statusCode, this.body);
}
