import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kebutuhan_model.dart';

class KebutuhanApi {
  final http.Client client;

  KebutuhanApi({required this.client});

  Future<List<KebutuhanModel>> getKebutuhan() async {
    final response = await client.get(
      Uri.parse('https://example.com/kebutuhan'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => KebutuhanModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load kebutuhan');
    }
  }
}