// lib/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import '../models/activity_data.dart';
import '../models/user_profile.dart';
import '../../../matches/data/models/match_record.dart';
import '../services/activity_service.dart';
import '../services/profile_service.dart';

/// Provider for user profile data that enables reactive UI updates
class ProfileProvider extends ChangeNotifier {
  bool _isLoading = true;
  String? _error;

  ProfileProvider() {
    ProfileService.instance.onProfileChanged = notifyListeners;
    _initProfile();
  }

  UserProfile? get profile => ProfileService.instance.currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _initProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ProfileService.instance.init();
      _error = null;
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await ProfileService.instance.updateProfile(displayName: name);
    } catch (e) {
      _error = 'Failed to update name: $e';
      notifyListeners();
    }
  }

  Future<void> updateAvatar(int index) async {
    try {
      await ProfileService.instance.updateProfile(avatarIndex: index);
    } catch (e) {
      _error = 'Failed to update avatar: $e';
      notifyListeners();
    }
  }

  Future<void> addBadge(String badgeId) async {
    try {
      await ProfileService.instance.addBadge(badgeId);
    } catch (e) {
      _error = 'Failed to add badge: $e';
      notifyListeners();
    }
  }

  Future<void> addPoints(int amount) async {
    try {
      await ProfileService.instance.addPoints(amount);
    } catch (e) {
      _error = 'Failed to add points: $e';
      notifyListeners();
    }
  }

  Future<void> addXP(int amount) async {
    try {
      await ProfileService.instance.addXP(amount);
    } catch (e) {
      _error = 'Failed to add XP: $e';
      notifyListeners();
    }
  }

  Future<void> recordMatchResult(MatchRecord record) async {
    try {
      await ProfileService.instance.recordMatch(record);
      await ActivityService.instance.recordActivity(ActivityType.match);
    } catch (e) {
      _error = 'Failed to record match: $e';
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await _initProfile();
  }
}
