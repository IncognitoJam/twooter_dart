import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:twooter_dart/src/twooter_event.dart';

import 'message.dart';
import 'http_response.dart';

/// The unofficial Twooter client for Dart!
class TwooterClient {
  /** BEGIN CONSTANTS */

  /// The default Twooter API URL, pointing to John Vidler's server
  static const String _TWOOTER_API_URL = 'http://twooter.johnvidler.co.uk';

  /// The default host for the Twooter live feed
  static const String _TWOOTER_LIVE_FEED_HOST = 'twooter.johnvidler.co.uk';

  /// The default port for the Twooter live feed
  static const int _TWOOTER_LIVE_FEED_PORT = 1337;

  /** END CONSTANTS */

  /** BEGIN HTTP */

  /// The URL this client will use when making Twooter requests.
  ///
  /// Defaults to [_TWOOTER_API_URL].
  final String apiUrl;

  /// Use Dio to make HTTP requests to the Twooter API.
  ///
  /// TODO: look again at dart:http so that we don't need an external dep
  Dio _dio;

  /** END HTTP */

  /** BEGIN WEB SOCKETS */

  /// The host address to connect to for the live feed web socket.
  ///
  /// Defaults to [_TWOOTER_LIVE_FEED_HOST].
  final String liveFeedHost;

  /// The port to connect to for the live feed web socket.
  ///
  /// Defaults to [_TWOOTER_LIVE_FEED_PORT].
  final int liveFeedPort;

  /// The socket for the live feed.
  Socket _liveFeedSocket;

  /// The set of twooter event listeners which will be called when a new message
  /// is received in the live feed.
  ///
  /// Register new listeners with [addEventListener].
  Set<TwooterEventListener> _liveFeedListeners;

  /** END WEB SOCKETS */

  /// Creates a new client instance.
  ///
  /// This does not by default connect to the live feed. If you want this
  /// functionality, you will need to write at least one [TwooterEventListener],
  /// register it with [addEventListener] and then call [enableLiveFeed].
  ///
  /// Ignoring the live feed, this class makes no persistent connections and
  /// each request will be serviced individually. This means that instances of
  /// the TwooterClient can be created and no network requests will be performed
  /// until one of the methods are called.
  TwooterClient(
      {this.apiUrl = _TWOOTER_API_URL,
      this.liveFeedHost = _TWOOTER_LIVE_FEED_HOST,
      this.liveFeedPort = _TWOOTER_LIVE_FEED_PORT}) {
    this._dio = Dio();
    this._liveFeedListeners = Set();
  }

  /// Attempts to determine if the web service is both *online* and *reachable*.
  Future<bool> isUp() async {
    final response = await _query('/');
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

  /// Enables (and connects to) the live feed service.
  bool enableLiveFeed() {
    if (this._liveFeedSocket != null) {
      // Live feed is already active
      return false;
    }

    // setup live feed
    _connectLiveFeed();
    return true;
  }

  /// Disables (and disconnects from) the live feed service.
  bool disableLiveFeed() {
    if (this._liveFeedSocket == null) {
      // No live feed is connected
      return false;
    }

    // close live feed
    _disconnectLiveFeed();
    return true;
  }

  /// Used to determine if the live feed is connected for this client.
  bool isLiveFeedConnected() {
    return this._liveFeedSocket != null;
  }

  /// Adds a function matching TwooterEventListener to the list of functions
  /// to be called on new live feed events.
  void addEventListener(TwooterEventListener eventListener) {
    this._liveFeedListeners.add(eventListener);
  }

  /// Removes the supplied function from the event listener list, preventing any
  /// further events from being sent to it.
  void removeEventListener(TwooterEventListener eventListener) {
    this._liveFeedListeners.remove(eventListener);
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

  /// Connect to the live feed web socket and begin listening for messages
  void _connectLiveFeed() async {
    // Connect the socket to the live feed
    final address = await InternetAddress.lookup(liveFeedHost);
    this._liveFeedSocket = await Socket.connect(address[0], liveFeedPort);
    print("Aaaaaaaaaaaaaaaah");

    // Set socket timeout
    this._liveFeedSocket.timeout(Duration(seconds: 60));

    // Listen for live feed messages
    this._liveFeedSocket.listen((message) {
      print('message: ${message}');

      if (message == null) {
        // ignore empty packet
        return;
      }

      String packet = message as String;
      final parts = packet.split(':');
      if (parts.length != 3) {
        // TODO: throw exception
        return;
      }

      // Read packet data
      String packetType = parts[0];
      String payload = parts[2];
      final twooterEvent = TwooterEvent.fromPacket(packetType, payload);
      this._notifyListeners(twooterEvent);
    });
  }

  /// Close the web socket channel
  void _disconnectLiveFeed() {
    this._liveFeedSocket.close();
  }

  /// Call every listener with the new event object
  void _notifyListeners(TwooterEvent event) {
    this._liveFeedListeners.forEach((listener) => listener(event));
  }
}
