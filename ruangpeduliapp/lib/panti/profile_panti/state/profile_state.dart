import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../api/profile_api.dart';

class ProfileState extends ChangeNotifier {
  final ProfileApi api;

  ProfileState({required this.api});

  ProfileModel? profile;
  bool isLoading = false;
  String? error;

  // =========================
  // LOAD PROFILE
  // =========================
  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      profile = await api.getProfile();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // =========================
  // UPDATE PROFILE
  // =========================
  Future<bool> updateProfile(ProfileModel newProfile) async {
    isLoading = true;
    notifyListeners();

    try {
      final success = await api.updateProfile(newProfile);

      if (success) {
        profile = newProfile;
      }

      return success;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}