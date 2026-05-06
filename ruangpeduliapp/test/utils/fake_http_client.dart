import 'package:http/http.dart' as http;

/// FakeClient untuk testing tanpa HTTP request real
class FakeClient extends http.BaseClient {
  final http.Response Function(http.BaseRequest) _onRequest;

  FakeClient(this._onRequest);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = _onRequest(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      request: request,
      headers: response.headers,
    );
  }
}
