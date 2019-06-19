import 'dart:io';

typedef Future<void> RequestHandler(HttpRequest request, HttpResponse response);

class TwooterServer {
  final String host;
  final int port;

  Map<String, RequestHandler> _requestHandlers;
  HttpServer _server;

  TwooterServer({this.host = 'localhost', this.port = 8080, autoStart = true}) {
    _registerHandlers();

    if (autoStart) {
      startServer();
    }
  }

  void _registerHandler(String uri, RequestHandler handler) {
    _requestHandlers[uri] = handler;
  }

  void _registerHandlers() {
    _requestHandlers = Map();

    // isUp
    _registerHandler('/', (_, response) async {
      response.write('OK');
      await response.close();
    });

    // getMessages
    _registerHandler('/messages', (_, response) async {
      response.write('[]');
      await response.close();
    });
  }

  /// Start listening for new requests.
  void startServer() async {
    if (_server != null) {
      // If server has already been setup, return immediately.
      return;
    }

    // Bind the Http Server to [host] and [port]
    _server = await HttpServer.bind(host, port);

    // Process all of the requests from the server
    await for (var request in _server) {
      print('[${DateTime.now().toIso8601String()}][${request.method}] ${request.uri}');

      // Only allow post requests
      if (request.method != 'POST') {
        return;
      }

      final uri = request.uri.toString();
      final handler = _requestHandlers[uri];

      // If no handler for this path, write an error message as the response
      if (handler == null) {
        request.response.write('No handler for ${uri}');
        await request.response.close();
        return;
      }

      // Run the handler with the request and response objects
      await handler(request, request.response);
    }
  }

  /// Permanently stop the server from listening for new connections.
  void stopServer() async {
    if (_server == null) {
      return;
    }

    // Close the http server
    await _server.close();
  }

  /// Determine whether or not the Twooter Server is online and accepting new
  /// connections.
  bool isServerOnline() {
    return _server != null;
  }
}
