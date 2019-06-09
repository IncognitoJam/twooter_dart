import 'dart:convert';

import 'package:dio/dio.dart';

import 'message.dart';
import 'http_response.dart';

/// The unofficial Twooter client for Dart!
///
/// TODO: add features to match official Java client
/// TODO: write response class for each request
class TwooterClient {
  /// The default Twooter API URL, pointing to John Vidler's server
  static const String _TWOOTER_API_URL = 'http://twooter.johnvidler.co.uk';

  /// The URL this client will use when making Twooter requests
  final String apiUrl;

  /// Use Dio to make HTTP requests to the Twooter API
  ///
  /// TODO: look again at dart:http so that we don't need an external
  ///   dependency
  Dio _dio;

  /// Creates a new client instance
  TwooterClient({this.apiUrl = _TWOOTER_API_URL}) {
    this._dio = Dio();
  }

  /// Attempts to determine if the web service is both *online* and *reachable*.
  Future<bool> isUp() async {
    final response = await _query('/');
    return response.statusCode == 200 && response.body == 'OK';
  }

  /// Attempt to register a new username.
  Future<String> registerName(String name) async {
    final response = await _query('/registerName', body: {'name': name});
    return response.body;
  }

  /// Retrieves a small number of messages from Twooter service (up to a maximum
  /// of 30) and returns them as a list of messages.
  Future<List<Message>> getMessages() async {
    final response = await _query('/messages');

    if (response.statusCode != 200) {
      // Bad request, return empty list
      return List();
    }

    // Read response as a list of json objects (maps from strings to any types)
    final list = response.body as List<Map<String, dynamic>>;
    // Convert each object from
    List<Message> messageList = list.map((i) => Message.fromJSON(i)).toList();

    return messageList;
  }

  /// Make a POST request to the Twooter service.
  ///
  /// A request is made to the provided [path] with an optional [body], which
  /// if provided is converted to the JSON format.
  Future<HTTPResponse> _query(String path, {Map body}) async {
    var response;

    if (body == null) {
      // Make a basic post request when no data is provided
      response = await _dio.post(_TWOOTER_API_URL + path);
    } else {
      // Make a post request with json encoded data
      response = await _dio.post(
        _TWOOTER_API_URL + path,
        data: jsonEncode(body),
        options: Options(
          /*
           * We don't want Dio to throw an error when we get a bad error code,
           * so we write a custom validateStatus function to allow all status
           * codes and return the response object.
           */
          validateStatus: (status) => true,
        ),
      );
    }

    // Return relevant data
    // TODO: encode JSON response?
    return HTTPResponse(response.statusCode, response.data);
  }
}
