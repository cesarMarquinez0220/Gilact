import 'package:equatable/equatable.dart';

/// Entidad que representa una sesión de visualización de video
class VideoSession extends Equatable {
  final String id;
  final String videoId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration totalWatchTime;
  final Duration currentPosition;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  const VideoSession({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.totalWatchTime,
    required this.currentPosition,
    required this.isCompleted,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    videoId,
    userId,
    startTime,
    endTime,
    totalWatchTime,
    currentPosition,
    isCompleted,
    metadata,
  ];

  VideoSession copyWith({
    String? id,
    String? videoId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? totalWatchTime,
    Duration? currentPosition,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
  }) {
    return VideoSession(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalWatchTime: totalWatchTime ?? this.totalWatchTime,
      currentPosition: currentPosition ?? this.currentPosition,
      isCompleted: isCompleted ?? this.isCompleted,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Duración de la sesión
  Duration get sessionDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  /// Verifica si la sesión está activa
  bool get isActive => endTime == null;
}
