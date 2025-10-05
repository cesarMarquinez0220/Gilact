import 'package:equatable/equatable.dart';

/// Entidad que representa el progreso de un video
class VideoProgress extends Equatable {
  final String videoId;
  final String userId;
  final Duration currentPosition;
  final Duration totalDuration;
  final double progressPercentage;
  final bool isCompleted;
  final DateTime lastWatchedAt;
  final int watchCount;

  const VideoProgress({
    required this.videoId,
    required this.userId,
    required this.currentPosition,
    required this.totalDuration,
    required this.progressPercentage,
    required this.isCompleted,
    required this.lastWatchedAt,
    required this.watchCount,
  });

  @override
  List<Object> get props => [
    videoId,
    userId,
    currentPosition,
    totalDuration,
    progressPercentage,
    isCompleted,
    lastWatchedAt,
    watchCount,
  ];

  VideoProgress copyWith({
    String? videoId,
    String? userId,
    Duration? currentPosition,
    Duration? totalDuration,
    double? progressPercentage,
    bool? isCompleted,
    DateTime? lastWatchedAt,
    int? watchCount,
  }) {
    return VideoProgress(
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      watchCount: watchCount ?? this.watchCount,
    );
  }
}
