import 'package:http/http.dart' as http;

/// A fake HTTP client for testing purposes.
/// It allows you to define a custom handler function
/// to return specific http.Response objects based on the request.
class FakeClient extends http.BaseClient {
  final http.Response Function(http.Request request) handler;

  FakeClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Cast BaseRequest to http.Request to access body, method, etc.
    final req = request as http.Request;
    // Call the provided handler function to get the response
    final response = handler(req);

    // Return a StreamedResponse from the http.Response
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}