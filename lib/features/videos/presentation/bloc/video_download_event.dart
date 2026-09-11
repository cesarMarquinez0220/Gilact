part of 'video_download_bloc.dart';

abstract class VideoDownloadEvent extends Equatable {
  const VideoDownloadEvent();

  @override
  List<Object?> get props => [];
}

class CheckVideoDownloadStatus extends VideoDownloadEvent {
  final String videoId;

  const CheckVideoDownloadStatus(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class DownloadVideoRequested extends VideoDownloadEvent {
  final Video video;

  const DownloadVideoRequested(this.video);

  @override
  List<Object?> get props => [video];
}

class CancelDownloadRequested extends VideoDownloadEvent {
  final String videoId;

  const CancelDownloadRequested(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class DeleteDownloadedVideoRequested extends VideoDownloadEvent {
  final String videoId;

  const DeleteDownloadedVideoRequested(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class GetAllDownloadedVideosRequested extends VideoDownloadEvent {
  const GetAllDownloadedVideosRequested();
}

class GetDownloadedSizeRequested extends VideoDownloadEvent {
  const GetDownloadedSizeRequested();
}

class UpdateVideoLastAccessed extends VideoDownloadEvent {
  final String videoId;

  const UpdateVideoLastAccessed(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class DownloadCompleted extends VideoDownloadEvent {
  final String videoId;

  const DownloadCompleted(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class DownloadFailed extends VideoDownloadEvent {
  final String videoId;
  final String error;

  const DownloadFailed(this.videoId, this.error);

  @override
  List<Object?> get props => [videoId, error];
}

