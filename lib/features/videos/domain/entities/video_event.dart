import 'package:equatable/equatable.dart';

/// Entidad que representa un evento de video
class VideoEvent extends Equatable {
  final String id;
  final String videoId;
  final String userId;
  final String eventType; // 'play', 'pause', 'seek', 'complete', etc.
  final Duration timestamp;
  final Duration? position;
  final Map<String, dynamic> metadata;

  const VideoEvent({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.eventType,
    required this.timestamp,
    this.position,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    videoId,
    userId,
    eventType,
    timestamp,
    position,
    metadata,
  ];

  VideoEvent copyWith({
    String? id,
    String? videoId,
    String? userId,
    String? eventType,
    Duration? timestamp,
    Duration? position,
    Map<String, dynamic>? metadata,
  }) {
    return VideoEvent(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      position: position ?? this.position,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Factory constructor para crear eventos comunes
  factory VideoEvent.play({
    required String videoId,
    required String userId,
    Duration? position,
  }) {
    return VideoEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      userId: userId,
      eventType: 'play',
      timestamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      position: position,
      metadata: const {},
    );
  }

  factory VideoEvent.pause({
    required String videoId,
    required String userId,
    Duration? position,
  }) {
    return VideoEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      userId: userId,
      eventType: 'pause',
      timestamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      position: position,
      metadata: const {},
    );
  }

  factory VideoEvent.seek({
    required String videoId,
    required String userId,
    required Duration fromPosition,
    required Duration toPosition,
  }) {
    return VideoEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      userId: userId,
      eventType: 'seek',
      timestamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      position: toPosition,
      metadata: {
        'fromPosition': fromPosition.inMilliseconds,
        'toPosition': toPosition.inMilliseconds,
      },
    );
  }

  factory VideoEvent.complete({
    required String videoId,
    required String userId,
    required Duration totalDuration,
  }) {
    return VideoEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      userId: userId,
      eventType: 'complete',
      timestamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      position: totalDuration,
      metadata: {'totalDuration': totalDuration.inMilliseconds},
    );
  }
}
