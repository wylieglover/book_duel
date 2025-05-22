// lib/services/activity_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';          // ← for kDebugMode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_data.dart';
import 'profile_service.dart';

class ActivityService {
  ActivityService._();
  static final ActivityService instance = ActivityService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final ProfileService _profileService = ProfileService.instance;

  DatabaseReference? _activityRef;
  final Map<String, List<ActivityData>> _cache = {};

  /// Must be called once after ProfileService.init()
  Future<void> init() async {
    debugPrint('⏳ Initializing ActivityService...');
    try {
      if (_profileService.uid != null) {
        _activityRef = _db.ref('activity/${_profileService.uid}');
        debugPrint('✅ Activity service initialized with Firebase');
      } else {
        debugPrint('⚠️ No user ID available, using local storage only');
      }
    } catch (e) {
      debugPrint('⚠️ Error initializing activity service: $e');
    }
    await _loadLocalCache();
  }

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _profileService.uid ?? 'local_user';

      final dates = prefs.getStringList('bookduel_activity_dates_$userId') ?? [];
      final counts = prefs.getStringList('bookduel_activity_counts_$userId') ?? [];
      final types = prefs.getStringList('bookduel_activity_types_$userId') ?? [];

      if (dates.length == counts.length && counts.length == types.length) {
        final List<ActivityData> list = [];
        for (var i = 0; i < dates.length; i++) {
          try {
            final date = DateTime.fromMillisecondsSinceEpoch(int.parse(dates[i]));
            final count = int.parse(counts[i]);
            final type = ActivityData.activityTypeFromString(types[i]);
            list.add(ActivityData(date: date, count: count, type: type));
          } catch (e) {
            debugPrint('⚠️ Error parsing activity cache entry: $e');
          }
        }
        _cache[userId] = list;
        debugPrint('✅ Loaded ${list.length} activity records from local storage');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading activity cache: $e');
    }
  }

  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _profileService.uid ?? 'local_user';
      final entries = _cache[userId] ?? [];

      final dates = <String>[];
      final counts = <String>[];
      final types = <String>[];
      for (var act in entries) {
        dates.add(act.date.millisecondsSinceEpoch.toString());
        counts.add(act.count.toString());
        types.add(act.type.toString().split('.').last);
      }

      await prefs.setStringList('bookduel_activity_dates_$userId', dates);
      await prefs.setStringList('bookduel_activity_counts_$userId', counts);
      await prefs.setStringList('bookduel_activity_types_$userId', types);

      debugPrint('✅ Saved ${entries.length} activity records to local storage');
    } catch (e) {
      debugPrint('⚠️ Error saving activity cache: $e');
    }
  }

  Future<void> recordActivity(ActivityType type) async {
    final userId = _profileService.uid ?? 'local_user';
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // ensure we have a list
    _cache.putIfAbsent(userId, () => []);

    final idx = _cache[userId]!.indexWhere((a) => isSameDay(a.date, today) && a.type == type);
    if (idx >= 0) {
      final existing = _cache[userId]![idx];
      _cache[userId]![idx] = ActivityData(
        date: today,
        count: existing.count + 1,
        type: type,
      );
    } else {
      _cache[userId]!.add(ActivityData(date: today, count: 1, type: type));
    }

    await _saveLocalCache();
    await _saveToFirebase(userId);
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _saveToFirebase(String userId) async {
    if (_activityRef == null) return;
    try {
      final activities = _cache[userId] ?? [];
      final Map<String, dynamic> payload = {};

      for (var act in activities) {
        final key = '${act.date.year}-${act.date.month.toString().padLeft(2, '0')}-${act.date.day.toString().padLeft(2, '0')}';
        payload.putIfAbsent(key, () => {})[act.type.toString().split('.').last] = act.count;
      }

      await _activityRef!.set(payload);
      debugPrint('✅ Saved activity data to Firebase');
    } catch (e) {
      debugPrint('⚠️ Error saving to Firebase: $e');
    }
  }

  /// Returns all activities for the current user.
  /// ← in debug builds, skips Firebase and returns local cache immediately.
  Future<List<ActivityData>> getActivityData() async {
    final userId = _profileService.uid ?? 'local_user';

    if (kDebugMode) {
      return _cache[userId] ?? [];
    }

    // production: try Firebase, then fallback to cache
    try {
      if (_activityRef != null) {
        final snap = await _activityRef!.get();
        if (snap.exists && snap.value != null) {
          final raw = snap.value as Map<dynamic, dynamic>;
          final List<ActivityData> list = [];
          raw.forEach((dateKey, typeMap) {
            try {
              final parts = (dateKey as String).split('-');
              final date = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
              (typeMap as Map).forEach((typeStr, cnt) {
                final type = ActivityData.activityTypeFromString(typeStr as String);
                list.add(ActivityData(date: date, count: cnt as int, type: type));
              });
            } catch (e) {
              debugPrint('⚠️ Error parsing Firebase entry: $e');
            }
          });
          _cache[userId] = list;
          await _saveLocalCache();
          return list;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching from Firebase: $e');
    }

    return _cache[userId] ?? [];
  }
}
