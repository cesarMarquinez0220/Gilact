import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/video.dart';
import '../../data/services/video_download_service.dart';
import '../../data/datasources/video_offline_local_data_source.dart';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';

part 'video_download_event.dart';
part 'video_download_state.dart';

/// BLoC para gestionar descargas de videos offline
class VideoDownloadBloc extends Bloc<VideoDownloadEvent, VideoDownloadState> {
  final VideoDownloadService _downloadService;
  final VideoOfflineLocalDataSource _localDataSource;

  // Mapa para mantener estados de múltiples descargas simultáneas
  final Map<String, Map<String, dynamic>> _activeDownloadsMap = {};

  VideoDownloadBloc({
    required VideoDownloadService downloadService,
    required VideoOfflineLocalDataSource localDataSource,
  }) : _downloadService = downloadService,
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
      final isDownloaded = await _localDataSource.isVideoDownloaded(
        event.videoId,
      );
      emit(
        VideoDownloadStatusChecked(
          videoId: event.videoId,
          isDownloaded: isDownloaded,
        ),
      );
    } catch (e) {
      emit(
        VideoDownloadError(
          'videos.download.checkStatusError'.tr(
            namedArgs: {'error': e.toString()},
          ),
        ),
      );
    }
  }

  Future<void> _onDownloadVideoRequested(
    DownloadVideoRequested event,
    Emitter<VideoDownloadState> emit,
  ) async {
    try {
      final videoId = event.video.id;

      // Actualizar el mapa de descargas activas
      _activeDownloadsMap[videoId] = {
        'isDownloading': true,
        'progress': 0.0,
        'bytesDownloaded': 0,
        'totalBytes': 0,
        'isDownloaded': false,
      };
      _emitMultipleDownloadsState(emit);

      String? errorMessage;

      try {
        await _downloadService.downloadVideo(
          event.video,
          onProgress: (progress) {
            if (progress.status == DownloadStatus.completed) {
              // Actualizar el mapa
              _activeDownloadsMap[videoId] = {
                'isDownloading': false,
                'progress': 1.0,
                'bytesDownloaded': progress.totalBytes,
                'totalBytes': progress.totalBytes,
                'isDownloaded': true,
              };

              // Emitir estado actualizado
              if (!emit.isDone) {
                _emitMultipleDownloadsState(emit);
                emit(VideoDownloadCompleted(videoId));
              }

              // Guardar información en base de datos local de forma asíncrona
              _saveVideoMetadata(event.video, progress)
                  .then((_) async {
                    // Verificar que el archivo se guardó correctamente
                    final isDownloaded = await _localDataSource
                        .isVideoDownloaded(videoId);
                    if (isDownloaded) {
                      // Actualizar el mapa
                      _activeDownloadsMap[videoId] = {
                        'isDownloading': false,
                        'progress': 1.0,
                        'bytesDownloaded': progress.totalBytes,
                        'totalBytes': progress.totalBytes,
                        'isDownloaded': true,
                      };

                      // Verificar si el emitter aún está activo antes de emitir
                      if (!emit.isDone) {
                        _emitMultipleDownloadsState(emit);
                        // Emitir estado verificado inmediatamente después de guardar
                        emit(
                          VideoDownloadStatusChecked(
                            videoId: videoId,
                            isDownloaded: true,
                          ),
                        );
                      }
                    } else {
                      _activeDownloadsMap.remove(videoId);
                      if (!emit.isDone) {
                        _emitMultipleDownloadsState(emit);
                        emit(
                          VideoDownloadError('videos.download.saveError'.tr()),
                        );
                      }
                    }
                  })
                  .catchError((e) {
                    _activeDownloadsMap.remove(videoId);
                    if (!emit.isDone) {
                      _emitMultipleDownloadsState(emit);
                      emit(
                        VideoDownloadError(
                          'videos.download.metadataError'.tr(
                            namedArgs: {'error': e.toString()},
                          ),
                        ),
                      );
                    }
                  });
            } else if (progress.status == DownloadStatus.failed) {
              errorMessage =
                  progress.errorMessage ?? 'common.unknownError'.tr();
              _activeDownloadsMap.remove(videoId);
              if (!emit.isDone) {
                _emitMultipleDownloadsState(emit);
                emit(
                  VideoDownloadError(
                    'videos.download.downloadError'.tr(
                      namedArgs: {
                        'error': errorMessage ?? 'common.unknownError'.tr(),
                      },
                    ),
                  ),
                );
              }
            } else {
              // Actualizar progreso en el mapa
              _activeDownloadsMap[videoId] = {
                'isDownloading': true,
                'progress': progress.progress,
                'bytesDownloaded': progress.bytesDownloaded,
                'totalBytes': progress.totalBytes,
                'isDownloaded': false,
              };

              if (!emit.isDone) {
                _emitMultipleDownloadsState(emit);
                emit(
                  VideoDownloadProgress(
                    videoId: videoId,
                    progress: progress.progress,
                    bytesDownloaded: progress.bytesDownloaded,
                    totalBytes: progress.totalBytes,
                  ),
                );
              }
            }
          },
        );
      } catch (e) {
        _activeDownloadsMap.remove(videoId);
        if (!emit.isDone) {
          _emitMultipleDownloadsState(emit);
          emit(
            VideoDownloadError(
              'videos.download.downloadError'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
          );
        }
      }
    } catch (e) {
      _activeDownloadsMap.remove(event.video.id);
      if (!emit.isDone) {
        _emitMultipleDownloadsState(emit);
        emit(VideoDownloadError('Error descargando video: $e'));
      }
    }
  }

  /// Emite el estado de múltiples descargas
  void _emitMultipleDownloadsState(Emitter<VideoDownloadState> emit) {
    if (!emit.isDone) {
      emit(MultipleDownloadsState(Map.from(_activeDownloadsMap)));
    }
  }

  Future<void> _saveVideoMetadata(
    Video video,
    DownloadProgress progress,
  ) async {
    try {
      final encryptedPath = await _downloadService.getDownloadedVideoPath(
        video.id,
      );
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

      await _localDataSource.saveOfflineVideo(
        model,
        originalVideoUrl: video.videoUrl,
      );
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
      _activeDownloadsMap.remove(event.videoId);
      if (!emit.isDone) {
        _emitMultipleDownloadsState(emit);
        emit(VideoDownloadCancelled(event.videoId));
      }
    } catch (e) {
      _activeDownloadsMap.remove(event.videoId);
      if (!emit.isDone) {
        _emitMultipleDownloadsState(emit);
        emit(VideoDownloadError('Error cancelando descarga: $e'));
      }
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
