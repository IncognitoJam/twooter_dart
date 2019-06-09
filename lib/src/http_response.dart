/// Wrapper for the basic response data we get from the Twooter API.
///
/// Contains a [statusCode] for the HTTP status code and the [body] of the
/// response which may be null if the request failed.
class HTTPResponse {
  /// HTTP status code
  final int statusCode;

  /// Response body of any type. Can be null.
  final dynamic body;

  /// Create a new [HTTPResponse] object
  HTTPResponse(this.statusCode, this.body);
}
