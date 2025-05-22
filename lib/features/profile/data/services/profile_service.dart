// lib/services/profile_service.dart
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../../../matches/data/models/match_record.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference? _profileRef;
  UserProfile? _cache;
  VoidCallback? onProfileChanged;

  String? get uid => _auth.currentUser?.uid;
  UserProfile? get currentProfile => _cache;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;  
    _initialized = true;        

    debugPrint('⏳ Initializing ProfileService...');

    try {
      if (_auth.currentUser == null) {
        final prefs = await SharedPreferences.getInstance();
        final storedEmail = prefs.getString('bookduel_auth_email');
        final storedPassword = prefs.getString('bookduel_auth_password');

        if (storedEmail != null && storedPassword != null) {
          try {
            await _auth.signInWithEmailAndPassword(
              email: storedEmail,
              password: storedPassword,
            );
          } catch (e) {
            await _createAnonymousAccount();
          }
        } else {
          await _createAnonymousAccount();
        }
      }

      if (_auth.currentUser != null) {
        _profileRef = _db.ref('profiles/${_auth.currentUser!.uid}');
        await loadProfile();
        _setupStream();
      } else {
        _setupLocalFallbackMode();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Unhandled error in ProfileService.init(): $e');
      debugPrintStack(stackTrace: stackTrace);
      _setupLocalFallbackMode();
    }
  }

  void _setupStream() {
    if (_profileRef != null && !kIsWeb) {
      _profileRef!.onValue.listen((event) {
        final value = event.snapshot.value;
        if (value != null) {
          final data = Map<dynamic, dynamic>.from(value as Map);
          _cache = UserProfile.fromJson(data);
          onProfileChanged?.call();
        }
      });
    }
  }

  void _setupLocalFallbackMode() {
    debugPrint('⚠️ Setting up local-only fallback mode');
  }

  Future<void> _createAnonymousAccount() async {
    final random = Random();
    final randomId = DateTime.now().millisecondsSinceEpoch.toString() + random.nextInt(100000).toString();
    final email = 'user_$randomId@bookduel.app';
    final password = 'Password_$randomId';

    await _auth.createUserWithEmailAndPassword(email: email, password: password);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookduel_auth_email', email);
    await prefs.setString('bookduel_auth_password', password);
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    if (_profileRef != null && uid != null) {
      try {
        final snap = await _profileRef!.get();
        if (snap.exists && snap.value != null) {
          final m = Map<dynamic, dynamic>.from(snap.value as Map);
          _cache = UserProfile.fromJson(m);
          return;
        }
      } catch (_) {}
    }

    final name = prefs.getString('bookduel_user_name') ?? prefs.getString('bookduel_display_name') ?? 'Reader';
    final avatar = prefs.getInt('bookduel_avatar_index') ?? 0;
    final points = prefs.getInt('bookduel_points_balance') ?? 0;

    _cache = UserProfile(
      uid: uid ?? 'local_user',
      displayName: name,
      avatarIndex: avatar,
      pointsBalance: points,
    );

    if (_profileRef != null && uid != null) {
      try {
        await saveProfile(_cache!);
      } catch (_) {}
    } else {
      _saveProfileLocally(_cache!);
    }
  }

  Future<void> _saveProfileLocally(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookduel_display_name', profile.displayName);
    await prefs.setInt('bookduel_avatar_index', profile.avatarIndex);
    await prefs.setInt('bookduel_points_balance', profile.pointsBalance);
  }

  Future<void> saveProfile(UserProfile profile) async {
    _cache = profile;
    await _saveProfileLocally(profile);

    if (_profileRef != null) {
      try {
        await _profileRef!.set(profile.toJson());
      } catch (_) {}
    }

    onProfileChanged?.call();
  }

  Future<void> updateProfile({
    String? displayName,
    int? avatarIndex,
    List<String>? badges,
    int? currentXP,
    int? currentLevel,
    int? wins,
    int? losses,
    int? pointsBalance,
    List<MatchRecord>? matchHistory,
  }) async {
    if (_cache == null) await loadProfile();
    if (_cache == null) return;

    final updated = _cache!.copyWith(
      displayName: displayName,
      avatarIndex: avatarIndex,
      badges: badges,
      currentXP: currentXP,
      currentLevel: currentLevel,
      wins: wins,
      losses: losses,
      pointsBalance: pointsBalance,
      matchHistory: matchHistory,
    );

    await saveProfile(updated);
  }

  Future<void> addBadge(String badgeId) async {
    if (_cache == null) return;
    final updatedBadges = List<String>.from(_cache!.badges);
    if (!updatedBadges.contains(badgeId)) {
      updatedBadges.add(badgeId);
      await updateProfile(badges: updatedBadges);
    }
  }

  Future<void> addPoints(int amount) async {
    if (_cache == null) return;
    final newBalance = _cache!.pointsBalance + amount;
    await updateProfile(pointsBalance: newBalance);
  }

  Future<void> addXP(int amount) async {
    if (_cache == null) return;
    int newXP = _cache!.currentXP + amount;
    int newLevel = _cache!.currentLevel;

    while (newXP >= _xpRequiredForNextLevel(newLevel)) {
      newXP -= _xpRequiredForNextLevel(newLevel);
      newLevel++;
    }

    await updateProfile(currentXP: newXP, currentLevel: newLevel);
  }

  int _xpRequiredForNextLevel(int level) => 100 + (level * 50);

  Future<void> recordMatch(MatchRecord record) async {
    if (_cache == null) return;

    final newHistory = List<MatchRecord>.from(_cache!.matchHistory)..add(record);
    int wins = _cache!.wins + (record.result == MatchResult.win ? 1 : 0);
    int losses = _cache!.losses + (record.result == MatchResult.loss ? 1 : 0);

    await updateProfile(
      matchHistory: newHistory,
      wins: wins,
      losses: losses,
    );

    if (record.pointsEarned > 0) await addPoints(record.pointsEarned);
    if (record.xpEarned > 0) await addXP(record.xpEarned);
  }

  Future<UserProfile?> fetchProfileByUid(String uid) async {
    try {
      final ref = _db.ref('profiles/$uid');
      final snap = await ref.get();
      if (!snap.exists || snap.value == null) return null;
      return UserProfile.fromJson(Map<dynamic, dynamic>.from(snap.value as Map));
    } catch (_) {
      return null;
    }
  }

  Stream<UserProfile?> streamProfileByUid(String uid) {
    try {
      final ref = _db.ref('profiles/$uid');
      return ref.onValue.map((e) {
        final v = e.snapshot.value;
        if (v == null) return null;
        return UserProfile.fromJson(Map<dynamic, dynamic>.from(v as Map));
      });
    } catch (_) {
      return Stream.value(null);
    }
  }
}