import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'video_encryption_service.dart';
import '../../domain/entities/video.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

/// Estado de descarga de un video
enum DownloadStatus {
  idle,
  downloading,
  encrypting,
  completed,
  failed,
  paused,
  cancelled,
}

/// Información de progreso de descarga
class DownloadProgress {
  final String videoId;
  final DownloadStatus status;
  final double progress; // 0.0 a 1.0
  final int bytesDownloaded;
  final int totalBytes;
  final String? errorMessage;

  DownloadProgress({
    required this.videoId,
    required this.status,
    this.progress = 0.0,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
    this.errorMessage,
  });

  DownloadProgress copyWith({
    String? videoId,
    DownloadStatus? status,
    double? progress,
    int? bytesDownloaded,
    int? totalBytes,
    String? errorMessage,
  }) {
    return DownloadProgress(
      videoId: videoId ?? this.videoId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Servicio para descargar videos de YouTube y almacenarlos de forma segura
class VideoDownloadService {
  final Dio _dio = Dio();
  final VideoEncryptionService _encryptionService = VideoEncryptionService();
  final Connectivity _connectivity = Connectivity();
  final AppLogger _logger = getIt<AppLogger>();

  // Directorio privado para videos descargados
  Directory? _downloadDirectory;

  // Map para rastrear descargas activas
  final Map<String, CancelToken> _activeDownloads = {};

  VideoDownloadService() {
    _initializeDio();
    _initializeDownloadDirectory();
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(
        minutes: 10,
      ), // Aumentado para videos largos
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) {
        // Aceptar códigos 200-299 y 300-399 (redirects)
        return status != null && status >= 200 && status < 400;
      },
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Accept-Language': 'es-ES,es;q=0.9,en;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Sec-Fetch-Dest': 'video',
        'Sec-Fetch-Mode': 'no-cors',
        'Sec-Fetch-Site': 'cross-site',
      },
    );

    // Interceptor para manejar errores específicos
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response?.statusCode == 403) {
            // Error 403: YouTube está bloqueando la descarga
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: DioExceptionType.badResponse,
                error:
                    'YouTube está bloqueando la descarga de este video. Esto puede deberse a restricciones del video o políticas de YouTube. Intenta más tarde o verifica que el video esté disponible públicamente.',
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Inicializa el directorio de descargas
  Future<void> _initializeDownloadDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _downloadDirectory = Directory('${appDir.path}/offline_videos');

      if (!await _downloadDirectory!.exists()) {
        await _downloadDirectory!.create(recursive: true);
      }
    } catch (e) {
      throw Exception('Error inicializando directorio de descargas: $e');
    }
  }

  /// Obtiene la URL directa del video desde YouTube usando youtube_explode_dart
  Future<String> _getVideoDirectUrl(String youtubeUrl) async {
    try {
      // Extraer ID del video de YouTube
      final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
      if (videoId == null) {
        throw Exception('No se pudo extraer el ID del video de YouTube');
      }

      // Usar youtube_explode_dart para obtener la URL directa
      final ytExplode = yt.YoutubeExplode();

      try {
        // Obtener manifest del video
        final manifest = await ytExplode.videos.streamsClient.getManifest(
          videoId,
        );

        // Obtener el stream de video con mejor calidad disponible
        // Priorizar: muxed (video + audio) > video only, mp4 > webm
        yt.VideoStreamInfo? videoStream;

        // Función auxiliar para comparar calidad de video
        int compareQuality(yt.VideoStreamInfo a, yt.VideoStreamInfo b) {
          // Usar el bitrate como indicador de calidad
          final qualityA = a.bitrate;
          final qualityB = b.bitrate;
          return qualityB.compareTo(qualityA); // Mayor calidad primero
        }

        // PRIORIDAD 1: Intentar obtener streams muxed (video + audio) - suelen tener menos restricciones
        final muxedStreams = manifest.muxed.toList();
        if (muxedStreams.isNotEmpty) {
          // Priorizar mp4 sobre webm
          final muxedMp4 = muxedStreams
              .where((stream) => stream.container.name == 'mp4')
              .toList();
          if (muxedMp4.isNotEmpty) {
            muxedMp4.sort(compareQuality);
            videoStream = muxedMp4.first;
          } else {
            // Si no hay mp4 muxed, usar cualquier muxed disponible
            muxedStreams.sort(compareQuality);
            videoStream = muxedStreams.first;
          }
        }

        // PRIORIDAD 2: Si no hay muxed, intentar video only mp4
        if (videoStream == null) {
          final mp4Streams = manifest.videoOnly
              .where((stream) => stream.container.name == 'mp4')
              .toList();
          if (mp4Streams.isNotEmpty) {
            mp4Streams.sort(compareQuality);
            videoStream = mp4Streams.first;
          }
        }

        // PRIORIDAD 3: Si aún no hay, usar cualquier video disponible
        if (videoStream == null) {
          final allVideoStreams = manifest.videoOnly.toList();
          if (allVideoStreams.isNotEmpty) {
            allVideoStreams.sort(compareQuality);
            videoStream = allVideoStreams.first;
          }
        }

        if (videoStream == null) {
          throw Exception('No se encontró un stream de video disponible');
        }

        final streamUrl = videoStream.url.toString();
        ytExplode.close();

        return streamUrl;
      } catch (e) {
        ytExplode.close();
        rethrow;
      }
    } catch (e) {
      throw Exception('Error obteniendo URL directa del video: $e');
    }
  }

  /// Descarga un video y lo encripta
  Future<String> downloadVideo(
    Video video, {
    required Function(DownloadProgress) onProgress,
  }) async {
    try {
      // Verificar conectividad
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty) {
        throw Exception('No hay conexión a internet');
      }

      final videoId = video.id;
      final cancelToken = CancelToken();
      _activeDownloads[videoId] = cancelToken;

      // Notificar inicio de descarga
      onProgress(
        DownloadProgress(
          videoId: videoId,
          status: DownloadStatus.downloading,
          progress: 0.0,
        ),
      );

      // Obtener URL directa del video
      final directUrl = await _getVideoDirectUrl(video.videoUrl);

      // Ruta del archivo temporal
      await _initializeDownloadDirectory();
      final tempFilePath = '${_downloadDirectory!.path}/$videoId.tmp';
      final finalFilePath = '${_downloadDirectory!.path}/$videoId.mp4';

      // Primero, obtener el tamaño esperado del archivo
      int? expectedFileSize;
      try {
        final headResponse = await _dio.head(
          directUrl,
          options: Options(
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept': '*/*',
              'Referer': 'https://www.youtube.com/',
            },
          ),
        );
        final contentLength = headResponse.headers.value('content-length');
        if (contentLength != null) {
          expectedFileSize = int.tryParse(contentLength);
          if (kDebugMode && expectedFileSize != null) {
            _logger.d('Tamaño esperado del archivo: $expectedFileSize bytes');
          }
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          _logger.w(
            'No se pudo obtener el tamaño esperado del archivo',
            e,
            stackTrace,
          );
        }
      }

      // Descargar el video con headers adicionales específicos para YouTube
      int? lastReceived = 0;
      await _dio.download(
        directUrl,
        tempFilePath,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Accept-Language': 'es-ES,es;q=0.9,en;q=0.8',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Referer': 'https://www.youtube.com/',
            'Origin': 'https://www.youtube.com',
          },
        ),
        onReceiveProgress: (received, total) {
          lastReceived = received;
          if (total > 0) {
            final progress = received / total;
            onProgress(
              DownloadProgress(
                videoId: videoId,
                status: DownloadStatus.downloading,
                progress: progress,
                bytesDownloaded: received,
                totalBytes: total,
              ),
            );
          }
        },
      );

      // Verificar que el archivo descargado existe y tiene contenido
      final tempFile = File(tempFilePath);
      if (!await tempFile.exists()) {
        throw Exception('El archivo descargado no existe');
      }

      final downloadedSize = await tempFile.length();
      if (downloadedSize == 0) {
        throw Exception('El archivo descargado está vacío');
      }

      if (kDebugMode) {
        _logger.d('Archivo descargado: $downloadedSize bytes');
        if (expectedFileSize != null) {
          if (downloadedSize != expectedFileSize) {
            _logger.w(
              'ADVERTENCIA: El tamaño del archivo descargado ($downloadedSize) no coincide con el tamaño esperado ($expectedFileSize)',
            );
            _logger.w(
              'Esto puede indicar que la descarga está incompleta o corrupta',
            );
          } else {
            _logger.success(
              'El tamaño del archivo descargado coincide con el tamaño esperado',
            );
          }
        }
        if (lastReceived != null && lastReceived! > 0) {
          if (downloadedSize != lastReceived) {
            _logger.w(
              'ADVERTENCIA: El tamaño del archivo ($downloadedSize) no coincide con los bytes recibidos ($lastReceived)',
            );
          }
        }
      }

      // Si tenemos el tamaño esperado y no coincide, lanzar error
      if (expectedFileSize != null && downloadedSize != expectedFileSize) {
        throw Exception(
          'La descarga está incompleta. Tamaño descargado: $downloadedSize bytes, '
          'Tamaño esperado: $expectedFileSize bytes. Por favor, intenta descargar el video nuevamente.',
        );
      }

      // Validar que el archivo descargado es un MP4 válido
      try {
        // Leer los primeros 1024 bytes para buscar "ftyp" y "moov"
        // "ftyp" debe estar al inicio, "moov" puede estar más adelante
        final firstBytes = await tempFile.openRead(0, 1024).first;
        final firstBytesList = firstBytes.toList();

        // Buscar "ftyp" en los primeros bytes (debe estar al inicio)
        bool foundFtyp = false;
        bool foundMoov = false;

        for (int i = 0; i <= firstBytesList.length - 4; i++) {
          final candidate = String.fromCharCodes(
            firstBytesList.sublist(i, i + 4),
          );
          if (candidate == 'ftyp') {
            foundFtyp = true;
            if (i > 8) {
              // "ftyp" debería estar cerca del inicio (después del tamaño del box)
              if (kDebugMode) {
                _logger.w(
                  'Advertencia: "ftyp" encontrado en posición $i, debería estar más cerca del inicio',
                );
              }
            }
          }
          if (candidate == 'moov') {
            foundMoov = true;
          }
        }

        // Si no encontramos "ftyp", buscar en todo el archivo (puede ser un MP4 fragmentado)
        if (!foundFtyp) {
          // Leer más bytes del archivo para buscar "ftyp"
          final moreBytes = await tempFile
              .openRead(0, downloadedSize > 8192 ? 8192 : downloadedSize)
              .first;
          final moreBytesList = moreBytes.toList();
          for (int i = 0; i <= moreBytesList.length - 4; i++) {
            final candidate = String.fromCharCodes(
              moreBytesList.sublist(i, i + 4),
            );
            if (candidate == 'ftyp') {
              foundFtyp = true;
              break;
            }
          }
        }

        if (!foundFtyp) {
          final hexSignature = firstBytesList
              .take(16)
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join(' ');
          if (kDebugMode) {
            _logger.e('ERROR: El archivo descargado no tiene firma MP4 válida');
            _logger.d('No se encontró "ftyp" en los primeros bytes');
            _logger.d('Primeros 16 bytes (hex): $hexSignature');
          }
          throw Exception(
            'El archivo descargado de YouTube está corrupto o no es un MP4 válido. '
            'No se encontró la firma "ftyp". Por favor, intenta descargar el video nuevamente.',
          );
        }

        if (kDebugMode) {
          _logger.success('Firma MP4 "ftyp" encontrada en archivo descargado');
          if (foundMoov) {
            _logger.success(
              'Estructura "moov" encontrada en archivo descargado',
            );
          } else {
            _logger.w(
              'Advertencia: No se encontró "moov" en los primeros bytes. '
              'Esto puede ser normal en MP4 fragmentados, pero puede indicar un archivo incompleto.',
            );
          }
        }
      } catch (e, stackTrace) {
        if (e.toString().contains('corrupto') ||
            e.toString().contains('MP4 válido') ||
            e.toString().contains('ftyp')) {
          rethrow;
        }
        if (kDebugMode) {
          _logger.w(
            'Advertencia: No se pudo validar la firma MP4',
            e,
            stackTrace,
          );
        }
      }

      // Notificar inicio de encriptación
      onProgress(
        DownloadProgress(
          videoId: videoId,
          status: DownloadStatus.encrypting,
          progress: 0.9,
        ),
      );

      // Encriptar el video
      final encryptedPath = await _encryptionService.encryptVideoFile(
        tempFilePath,
      );

      // Mover archivo encriptado a la ubicación final
      final encryptedFile = File(encryptedPath);
      final finalEncryptedFile = File('$finalFilePath.encrypted');
      await encryptedFile.rename(finalEncryptedFile.path);

      // Limpiar
      _activeDownloads.remove(videoId);

      // Notificar completado
      onProgress(
        DownloadProgress(
          videoId: videoId,
          status: DownloadStatus.completed,
          progress: 1.0,
        ),
      );

      return finalEncryptedFile.path;
    } catch (e) {
      _activeDownloads.remove(video.id);
      onProgress(
        DownloadProgress(
          videoId: video.id,
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        ),
      );
      throw Exception('Error descargando video: $e');
    }
  }

  /// Cancela una descarga en progreso
  void cancelDownload(String videoId) {
    final cancelToken = _activeDownloads[videoId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
      _activeDownloads.remove(videoId);
    }
  }

  /// Verifica si un video está descargado
  Future<bool> isVideoDownloaded(String videoId) async {
    try {
      await _initializeDownloadDirectory();
      final encryptedFile = File(
        '${_downloadDirectory!.path}/$videoId.mp4.encrypted',
      );
      return await encryptedFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la ruta del archivo encriptado
  Future<String?> getDownloadedVideoPath(String videoId) async {
    try {
      await _initializeDownloadDirectory();
      final encryptedFile = File(
        '${_downloadDirectory!.path}/$videoId.mp4.encrypted',
      );
      if (await encryptedFile.exists()) {
        return encryptedFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Elimina un video descargado
  Future<void> deleteDownloadedVideo(String videoId) async {
    try {
      await _initializeDownloadDirectory();
      final encryptedFile = File(
        '${_downloadDirectory!.path}/$videoId.mp4.encrypted',
      );
      if (await encryptedFile.exists()) {
        await encryptedFile.delete();
      }
    } catch (e) {
      throw Exception('Error eliminando video descargado: $e');
    }
  }

  /// Obtiene el tamaño total de todos los videos descargados
  Future<int> getTotalDownloadedSize() async {
    try {
      await _initializeDownloadDirectory();
      if (_downloadDirectory == null || !await _downloadDirectory!.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in _downloadDirectory!.list()) {
        if (entity is File && entity.path.endsWith('.encrypted')) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene el directorio de descargas
  Future<Directory> getDownloadDirectory() async {
    await _initializeDownloadDirectory();
    return _downloadDirectory!;
  }
}
