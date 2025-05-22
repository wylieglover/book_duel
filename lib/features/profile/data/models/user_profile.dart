// lib/models/user_profile.dart

import '../../../matches/data/models/match_record.dart';

/// Represents a user and their profile data, including stats, history, and in-app points.
class UserProfile {
  final String uid;
  final String displayName;
  final int avatarIndex;
  final List<String> badges;
  final int currentXP;
  final int currentLevel;
  final int wins;
  final int losses;
  final int pointsBalance;
  final List<MatchRecord> matchHistory;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.avatarIndex,
    this.badges = const [],
    this.currentXP = 0,
    this.currentLevel = 1,
    this.wins = 0,
    this.losses = 0,
    this.pointsBalance = 0,
    this.matchHistory = const [],
  });

  /// Creates a copy with updated fields.
  UserProfile copyWith({
    String? displayName,
    int? avatarIndex,
    List<String>? badges,
    int? currentXP,
    int? currentLevel,
    int? wins,
    int? losses,
    int? pointsBalance,
    List<MatchRecord>? matchHistory,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      badges: badges ?? this.badges,
      currentXP: currentXP ?? this.currentXP,
      currentLevel: currentLevel ?? this.currentLevel,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      matchHistory: matchHistory ?? this.matchHistory,
    );
  }

  /// Constructs a [UserProfile] from JSON data.
  factory UserProfile.fromJson(Map<dynamic, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      avatarIndex: (json['avatarIndex'] as num).toInt(),
      badges: List<String>.from(json['badges'] as List? ?? []),
      currentXP: (json['currentXP'] as num?)?.toInt() ?? 0,
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      matchHistory: (json['matchHistory'] as List?)
              ?.map((e) => MatchRecord.fromJson(Map<String, dynamic>.from(e)))
              .toList() ?? [],
    );
  }

  /// Converts this [UserProfile] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'avatarIndex': avatarIndex,
      'badges': badges,
      'currentXP': currentXP,
      'currentLevel': currentLevel,
      'wins': wins,
      'losses': losses,
      'pointsBalance': pointsBalance,
      'matchHistory': matchHistory.map((m) => m.toJson()).toList(),
    };
  }
}