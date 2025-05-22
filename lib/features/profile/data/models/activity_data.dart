// lib/models/activity_data.dart

enum ActivityType {
  match,
  reading,
  bookAdded,
  levelUp,
  other,
}

class ActivityData {
  final DateTime date;
  final int count;
  final ActivityType type;

  ActivityData({
    required this.date,
    required this.count,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'date': date.millisecondsSinceEpoch,
        'count': count,
        'type': type.toString().split('.').last,
      };

  factory ActivityData.fromJson(Map<dynamic, dynamic> json) {
    return ActivityData(
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      count: json['count'] as int,
      type: ActivityData.activityTypeFromString(json['type'] as String),
    );
  }

  /// PUBLIC parser for converting the string back into an enum.
  static ActivityType activityTypeFromString(String typeStr) {
    return ActivityType.values.firstWhere(
      (type) => type.toString().split('.').last == typeStr,
      orElse: () => ActivityType.other,
    );
  }
}
