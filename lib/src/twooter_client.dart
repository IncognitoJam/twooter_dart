import 'package:http/http.dart' as http;

// The official Twooter client for Dart!
//
// TODO: add features to match official Java client
class TwooterClient {
  static final String _TWOOTER_API_URL = 'http://twooter.johnvidler.co.uk';

  // Creates a new client instance
  TwooterClient();

  // Attempts to determine if the web service is both *online* and *reachable*.
  Future<bool> isUp() async {
    var response = await _query('/');
    return response.statusCode == 200 && response.body == 'OK';
  }

  Future<http.Response> _query(String path, {dynamic body}) async =>
      await http.post(_TWOOTER_API_URL + path, body: body);
}
