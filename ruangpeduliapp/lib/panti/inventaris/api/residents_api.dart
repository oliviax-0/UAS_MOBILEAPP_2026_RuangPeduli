import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ruangpeduliapp/panti/inventaris/models/anggota_model.dart';

class ResidentsApi {
  final http.Client client;
  final String baseUrl = 'http://api.example.com';

  ResidentsApi({required this.client});

  /// Get list of residents
  Future<List<AnggotaModel>> getResidents() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/residents'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => AnggotaModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load residents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Add new resident
  Future<bool> addResident(AnggotaModel anggota) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/residents'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anggota.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add resident: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Delete resident by ID
  Future<bool> deleteResident(int id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/residents/$id'));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete resident: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
