import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

class ProfileApi {
  final http.Client client;

  ProfileApi({required this.client});

  // GET PROFILE
  Future<ProfileModel> getProfile() async {
    final response = await client.get(
      Uri.parse('https://example.com/profile'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ProfileModel.fromJson(data);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // UPDATE PROFILE
  Future<bool> updateProfile(ProfileModel profile) async {
    final response = await client.put(
      Uri.parse('https://example.com/profile'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile');
    }
  }
}