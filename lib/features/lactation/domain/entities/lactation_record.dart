class LactationRecord {
  final String id;
  final DateTime dateTime;
  final Duration duration;
  final LactationType type;
  final String? notes;
  final String? side; // 'left', 'right', 'both'

  LactationRecord({
    required this.id,
    required this.dateTime,
    required this.duration,
    required this.type,
    this.notes,
    this.side,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'duration': duration.inMinutes,
      'type': type.name,
      'notes': notes,
      'side': side,
    };
  }

  factory LactationRecord.fromMap(Map<String, dynamic> map) {
    return LactationRecord(
      id: map['id'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      duration: Duration(minutes: map['duration']),
      type: LactationType.values.firstWhere((e) => e.name == map['type']),
      notes: map['notes'],
      side: map['side'],
    );
  }

  LactationRecord copyWith({
    String? id,
    DateTime? dateTime,
    Duration? duration,
    LactationType? type,
    String? notes,
    String? side,
  }) {
    return LactationRecord(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      side: side ?? this.side,
    );
  }
}

enum LactationType {
  breastfeeding, // Lactancia directa
  pumping, // Extracción
  bottle, // Biberón con leche materna
}

class LactationStats {
  final int totalFeeds;
  final Duration totalDuration;
  final Duration averageDuration;
  final int feedsToday;
  final Duration durationToday;

  LactationStats({
    required this.totalFeeds,
    required this.totalDuration,
    required this.averageDuration,
    required this.feedsToday,
    required this.durationToday,
  });
}
