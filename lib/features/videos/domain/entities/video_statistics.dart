import 'package:equatable/equatable.dart';

/// Entidad que representa estadísticas de un video
class VideoStatistics extends Equatable {
  final String videoId;
  final String userId;
  final int totalViews;
  final int uniqueViews;
  final Duration totalWatchTime;
  final Duration averageWatchTime;
  final double completionRate;
  final int pauseCount;
  final int seekCount;
  final DateTime firstWatchedAt;
  final DateTime lastWatchedAt;
  final Map<String, dynamic> additionalMetrics;

  const VideoStatistics({
    required this.videoId,
    required this.userId,
    required this.totalViews,
    required this.uniqueViews,
    required this.totalWatchTime,
    required this.averageWatchTime,
    required this.completionRate,
    required this.pauseCount,
    required this.seekCount,
    required this.firstWatchedAt,
    required this.lastWatchedAt,
    required this.additionalMetrics,
  });

  @override
  List<Object> get props => [
    videoId,
    userId,
    totalViews,
    uniqueViews,
    totalWatchTime,
    averageWatchTime,
    completionRate,
    pauseCount,
    seekCount,
    firstWatchedAt,
    lastWatchedAt,
    additionalMetrics,
  ];

  VideoStatistics copyWith({
    String? videoId,
    String? userId,
    int? totalViews,
    int? uniqueViews,
    Duration? totalWatchTime,
    Duration? averageWatchTime,
    double? completionRate,
    int? pauseCount,
    int? seekCount,
    DateTime? firstWatchedAt,
    DateTime? lastWatchedAt,
    Map<String, dynamic>? additionalMetrics,
  }) {
    return VideoStatistics(
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      totalViews: totalViews ?? this.totalViews,
      uniqueViews: uniqueViews ?? this.uniqueViews,
      totalWatchTime: totalWatchTime ?? this.totalWatchTime,
      averageWatchTime: averageWatchTime ?? this.averageWatchTime,
      completionRate: completionRate ?? this.completionRate,
      pauseCount: pauseCount ?? this.pauseCount,
      seekCount: seekCount ?? this.seekCount,
      firstWatchedAt: firstWatchedAt ?? this.firstWatchedAt,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      additionalMetrics: additionalMetrics ?? this.additionalMetrics,
    );
  }

  /// Calcula la tasa de retención
  double get retentionRate {
    if (totalViews == 0) return 0.0;
    return (uniqueViews / totalViews) * 100;
  }

  /// Verifica si el video es popular
  bool get isPopular => totalViews > 100 && completionRate > 0.7;
}
