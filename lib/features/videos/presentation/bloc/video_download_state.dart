part of 'video_download_bloc.dart';

abstract class VideoDownloadState extends Equatable {
  const VideoDownloadState();

  @override
  List<Object?> get props => [];
}

class VideoDownloadInitial extends VideoDownloadState {}

class VideoDownloadStatusChecked extends VideoDownloadState {
  final String videoId;
  final bool isDownloaded;

  const VideoDownloadStatusChecked({
    required this.videoId,
    required this.isDownloaded,
  });

  @override
  List<Object?> get props => [videoId, isDownloaded];
}

class VideoDownloadInProgress extends VideoDownloadState {
  final String videoId;

  const VideoDownloadInProgress(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class VideoDownloadProgress extends VideoDownloadState {
  final String videoId;
  final double progress;
  final int bytesDownloaded;
  final int totalBytes;

  const VideoDownloadProgress({
    required this.videoId,
    required this.progress,
    required this.bytesDownloaded,
    required this.totalBytes,
  });

  @override
  List<Object?> get props => [videoId, progress, bytesDownloaded, totalBytes];
}

class VideoDownloadCompleted extends VideoDownloadState {
  final String videoId;

  const VideoDownloadCompleted(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class VideoDownloadCancelled extends VideoDownloadState {
  final String videoId;

  const VideoDownloadCancelled(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class VideoDownloadDeleted extends VideoDownloadState {
  final String videoId;

  const VideoDownloadDeleted(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class AllDownloadedVideosLoaded extends VideoDownloadState {
  final List<OfflineVideoModel> videos;

  const AllDownloadedVideosLoaded(this.videos);

  @override
  List<Object?> get props => [videos];
}

class DownloadedSizeLoaded extends VideoDownloadState {
  final int totalSizeBytes;

  const DownloadedSizeLoaded(this.totalSizeBytes);

  @override
  List<Object?> get props => [totalSizeBytes];
}

class VideoDownloadError extends VideoDownloadState {
  final String message;

  const VideoDownloadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado que mantiene información de múltiples descargas simultáneas
class MultipleDownloadsState extends VideoDownloadState {
  /// Mapa de estados de descarga por videoId
  /// La clave es el videoId y el valor es un mapa con:
  /// - 'isDownloading': bool
  /// - 'progress': double (0.0 a 1.0)
  /// - 'bytesDownloaded': int
  /// - 'totalBytes': int
  /// - 'isDownloaded': bool
  final Map<String, Map<String, dynamic>> downloads;

  const MultipleDownloadsState(this.downloads);

  MultipleDownloadsState copyWith({
    Map<String, Map<String, dynamic>>? downloads,
  }) {
    return MultipleDownloadsState(downloads ?? this.downloads);
  }

  @override
  List<Object?> get props => [downloads];
}

