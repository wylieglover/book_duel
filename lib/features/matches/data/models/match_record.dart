// lib/models/match_record.dart

/// Represents the outcome of a match
enum MatchResult {
  win,
  loss,
  draw,
  abandoned
}

/// Records a single match's details and outcome
class MatchRecord {
  final String sessionId;
  final String opponentUid;
  final String opponentName;
  final DateTime timestamp;
  final MatchResult result;
  final int pointsEarned;
  final int xpEarned;
  final Map<String, dynamic>? metadata;

  const MatchRecord({
    required this.sessionId,
    required this.opponentUid,
    required this.opponentName,
    required this.timestamp,
    required this.result,
    this.pointsEarned = 0,
    this.xpEarned = 0,
    this.metadata,
  });

  /// Creates a [MatchRecord] from JSON data
  factory MatchRecord.fromJson(Map<dynamic, dynamic> json) {
    return MatchRecord(
      sessionId: json['sessionId'] as String,
      opponentUid: json['opponentUid'] as String,
      opponentName: json['opponentName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      result: MatchResult.values.firstWhere(
        (e) => e.name == (json['result'] as String),
        orElse: () => MatchResult.abandoned,
      ),
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts this [MatchRecord] to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'opponentUid': opponentUid,
      'opponentName': opponentName,
      'timestamp': timestamp.toIso8601String(),
      'result': result.name,
      'pointsEarned': pointsEarned,
      'xpEarned': xpEarned,
      'metadata': metadata,
    };
  }
}