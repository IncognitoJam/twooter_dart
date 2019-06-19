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
    print('body: ${response.body}');
    return response.statusCode == 200 && response.body == 'OK';
  }

  /// Attempt to register a new username, returning a token if successful.
  ///
  /// The token can be used to make further requests to the Twooter API with
  /// this identity, for example to post messages. Null will be returned if
  /// not successful, such as when an invalid name is provided or it has
  /// already been registered.
  ///
  /// Use [isActiveName] to check whether or not a username is available.
  Future<String> registerName(String name) async {
    final response = await _query('/registerName', body: {'name': name});
    return response.body;
  }

  /// Contacts the Twooter service to check if a name exists and is active.
  ///
  /// ```dart
  /// final username = 'Twooter-Internals';
  /// final isActive = await client.isActiveName(username);
  ///
  /// print(isActive); // true
  /// ```
  Future<bool> isActiveName(String name) async {
    final response = await _query('/isName', body: {'name': name});
    return response.statusCode == 200;
  }

  /// Refresh the token timeout for a particular username.
  ///
  /// Returns true if successful, or false if the token has expired for this
  /// username already.
  Future<bool> refreshName(String name, String token) async {
    final response =
        await _query('/refreshName', body: {'name': name, 'token': token});
    return response.statusCode == 200;
  }

  /// Posts a message to the Twooter feed.
  Future<String> postMessage(String token, String name, String message) async {
    final response = await _query('/postMessage', body: {
      'token': token,
      'name': name,
      'message': message,
    });

    // if no response, return null
    if (response.statusCode != 200) {
      return null;
    }

    return response.body;
  }

  /// Retrieves a single message from Twooter, using the message [id].
  Future<Message> getMessage(String id) async {
    final response = await _query('/message/${id}');
    if (response.statusCode != 200 || response.body == null) {
      return null;
    }

    return Message.fromJSON(response.body);
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
    final list = response.body as List<dynamic>;
    // Convert each object from
    List<Message> messageList = list.map((i) => Message.fromJSON(i)).toList();

    return messageList;
  }

  /// Retrieves a list of message IDs for messages tagged with [tag].
  Future<List<String>> getTagged(String tag) async {
    final query = tag.replaceAll('#', '%23');
    final response = await _query('/tagged/${query}');

    // if response is empty, return an empty list
    if (response.statusCode != 200 || response.body == null) {
      return List();
    }

    return (response.body as String).split('\n');
  }

  /// Make a POST request to the Twooter service.
  ///
  /// A request is made to the provided [path] with an optional [body], which
  /// if provided is converted to the JSON format.
  Future<HTTPResponse> _query(String path, {Map body}) async {
    var response;

    if (body == null) {
      // Make a basic post request when no data is provided
      response = await _dio.post(apiUrl + path);
    } else {
      // Make a post request with json encoded data
      response = await _dio.post(
        apiUrl + path,
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
