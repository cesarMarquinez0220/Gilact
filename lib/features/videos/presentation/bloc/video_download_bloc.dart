import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/video.dart';
import '../../data/services/video_download_service.dart';
import '../../data/datasources/video_offline_local_data_source.dart';
import 'dart:io';
import 'dart:typed_data';

part 'video_download_event.dart';
part 'video_download_state.dart';

/// BLoC para gestionar descargas de videos offline
class VideoDownloadBloc extends Bloc<VideoDownloadEvent, VideoDownloadState> {
  final VideoDownloadService _downloadService;
  final VideoOfflineLocalDataSource _localDataSource;

  VideoDownloadBloc({
    required VideoDownloadService downloadService,
    required VideoOfflineLocalDataSource localDataSource,
  })  : _downloadService = downloadService,
        _localDataSource = localDataSource,
        super(VideoDownloadInitial()) {
    on<CheckVideoDownloadStatus>(_onCheckVideoDownloadStatus);
    on<DownloadVideoRequested>(_onDownloadVideoRequested);
    on<CancelDownloadRequested>(_onCancelDownloadRequested);
    on<DeleteDownloadedVideoRequested>(_onDeleteDownloadedVideoRequested);
    on<GetAllDownloadedVideosRequested>(_onGetAllDownloadedVideosRequested);
    on<GetDownloadedSizeRequested>(_onGetDownloadedSizeRequested);
    on<UpdateVideoLastAccessed>(_onUpdateVideoLastAccessed);
    on<DownloadCompleted>(_onDownloadCompleted);
    on<DownloadFailed>(_onDownloadFailed);
  }

  Future<void> _onCheckVideoDownloadStatus(
    CheckVideoDownloadStatus event,
    Emitter<VideoDownloadState> emit,
  ) async {
    try {
      final isDownloaded = await _localDataSource.isVideoDownloaded(event.videoId);
      emit(VideoDownloadStatusChecked(
        videoId: event.videoId,
        isDownloaded: isDownloaded,
      ));
    } catch (e) {
      emit(VideoDownloadError('Error verificando estado: $e'));
    }
  }

  Future<void> _onDownloadVideoRequested(
    DownloadVideoRequested event,
    Emitter<VideoDownloadState> emit,
  ) async {
    try {
      emit(VideoDownloadInProgress(event.video.id));

      String? errorMessage;
      
      try {
        await _downloadService.downloadVideo(
          event.video,
          onProgress: (progress) {
            if (progress.status == DownloadStatus.completed) {
              // Guardar información en base de datos local
              _saveVideoMetadata(event.video, progress);
              emit(VideoDownloadCompleted(event.video.id));
            } else if (progress.status == DownloadStatus.failed) {
              errorMessage = progress.errorMessage ?? 'Error desconocido';
              emit(VideoDownloadError('Error descargando video: $errorMessage'));
            } else {
              emit(VideoDownloadProgress(
                videoId: event.video.id,
                progress: progress.progress,
                bytesDownloaded: progress.bytesDownloaded,
                totalBytes: progress.totalBytes,
              ));
            }
          },
        );
      } catch (e) {
        emit(VideoDownloadError('Error descargando video: $e'));
      }
    } catch (e) {
      emit(VideoDownloadError('Error descargando video: $e'));
    }
  }

  Future<void> _saveVideoMetadata(Video video, DownloadProgress progress) async {
    try {
      final encryptedPath = await _downloadService.getDownloadedVideoPath(video.id);
      if (encryptedPath == null) return;

      final encryptedFile = File(encryptedPath);
      final fileSize = await encryptedFile.length();

      final model = OfflineVideoModel(
        videoId: video.id,
        title: video.title,
        description: video.description,
        imageUrl: video.imageUrl,
        imageName: video.imageName,
        lessonId: video.lessonId,
        videoIdNumber: video.videoId,
        duration: video.duration,
        encryptedFilePath: encryptedPath,
        fileSizeBytes: fileSize,
        downloadedAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
        order: video.order,
      );

      await _localDataSource.saveOfflineVideo(model, originalVideoUrl: video.videoUrl);
    } catch (e) {
      print('Error guardando metadata: $e');
    }
  }

  Future<void> _onCancelDownloadRequested(
    CancelDownloadRequested event,
    Emitter<VideoDownloadState> emit,
  ) async {
    try {
      _downloadService.cancelDownload(event.videoId);
      emit(VideoDownloadCancelled(event.videoId));
    } catch (e) {
      emit(VideoDownloadError('Error cancelando descarga: $e'));
    }
  }

  Future<void> _onDeleteDownloadedVideoRequested(
    DeleteDownloadedVideoRequested event,
    Emitter<VideoDownloadState> emit,
  ) async {
    try {
      await _downloadService.deleteDownloadedVideo(event.videoId);
      await _localDataSource.deleteOfflineVideo(event.videoId);
      emit(VideoDownloadDeleted(event.videoId));
    } catch (e) {
      emit(VideoDownloadError('Error eliminando video: $e'));
    }
  }

  Future<void> _onGetAllDownloadedVideosRequested(
    GetAllDownloadedVideosRequested event,
    Emitter<VideoDownloadState> emit,
  ) async {
    try {
      final videos = await _localDataSource.getAllOfflineVideos();
      emit(AllDownloadedVideosLoaded(videos));
    } catch (e) {
      emit(VideoDownloadError('Error cargando videos: $e'));
    }
  }

  Future<void> _onGetDownloadedSizeRequested(
    GetDownloadedSizeRequested event,
    Emitter<VideoDownloadState> emit,
  ) async {
    try {
      final totalSize = await _localDataSource.getTotalDownloadedSize();
      emit(DownloadedSizeLoaded(totalSize));
    } catch (e) {
      emit(VideoDownloadError('Error obteniendo tamaño: $e'));
    }
  }

  Future<void> _onUpdateVideoLastAccessed(
    UpdateVideoLastAccessed event,
    Emitter<VideoDownloadState> emit,
  ) async {
    try {
      await _localDataSource.updateLastAccessed(event.videoId);
    } catch (e) {
      // No emitir error para esta operación silenciosa
      print('Error actualizando último acceso: $e');
    }
  }

  Future<void> _onDownloadCompleted(
    DownloadCompleted event,
    Emitter<VideoDownloadState> emit,
  ) async {
    emit(VideoDownloadCompleted(event.videoId));
  }

  Future<void> _onDownloadFailed(
    DownloadFailed event,
    Emitter<VideoDownloadState> emit,
  ) async {
    emit(VideoDownloadError('Error descargando video: ${event.error}'));
  }
}

