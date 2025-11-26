import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../domain/entities/video.dart';
import '../../data/services/video_encryption_service.dart';
import '../../data/services/video_download_service.dart';
import '../../data/services/video_progress_service.dart';
import '../../data/services/video_interaction_service.dart';
import '../../../../core/services/screen_recording_prevention_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';
import '../../../lessons/presentation/providers/lecciones_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

/// Reproductor de video offline con desencriptación por chunks
class OfflineVideoPlayer extends StatefulWidget {
  final Video video;
  final VoidCallback? onVideoCompleted;
  final VoidCallback? onVideoReady;
  final bool isFromHistory;

  const OfflineVideoPlayer({
    super.key,
    required this.video,
    this.onVideoCompleted,
    this.onVideoReady,
    this.isFromHistory = false,
  });

  @override
  State<OfflineVideoPlayer> createState() => _OfflineVideoPlayerState();

  /// Método estático para acceder al estado y reiniciar el video
  static void replayVideo(GlobalKey key) {
    final state = key.currentState;
    if (state is _OfflineVideoPlayerState) {
      state._replayVideo();
    }
  }
}

class _OfflineVideoPlayerState extends State<OfflineVideoPlayer> {
  final AppLogger _logger = getIt<AppLogger>();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  final VideoEncryptionService _encryptionService = VideoEncryptionService();
  final VideoDownloadService _downloadService = VideoDownloadService();
  final VideoProgressService _progressService = VideoProgressService();
  final VideoInteractionService _interactionService =
      GetIt.instance<VideoInteractionService>();

  bool _isInitializing = true;
  // ignore: unused_field
  bool _isPaused = false;
  bool _wasAlreadyCompleted = false;
  double _lastSavedProgress = 0.0;
  Timer? _progressSaveTimer;
  File? _decryptedVideoFile;
  StreamSubscription<bool>? _recordingStatusSubscription;

  @override
  void initState() {
    super.initState();
    // Activar prevención de grabación de pantalla
    ScreenRecordingPreventionService.enableScreenProtection();

    // Escuchar cambios en el estado de grabación
    _recordingStatusSubscription =
        ScreenRecordingPreventionService.watchScreenRecordingStatus().listen((
          isRecording,
        ) {
          if (isRecording && mounted) {
            // Pausar el video si se detecta grabación
            _videoController?.pause();
            _chewieController?.pause();
            _logger.w('Grabación de pantalla detectada - Video pausado');
            // Mostrar mensaje al usuario
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'La grabación de pantalla no está permitida durante la reproducción',
                ),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
          }
        });

    _initializeOfflinePlayer();
  }

  Future<void> _initializeOfflinePlayer() async {
    try {
      _logger.d('Iniciando reproductor offline para video: ${widget.video.id}');

      // Verificar si el video está descargado
      final isDownloaded = await _downloadService.isVideoDownloaded(
        widget.video.id,
      );

      if (!isDownloaded) {
        throw Exception('Video no está descargado');
      }

      _logger.d('Video verificado como descargado');

      // Obtener ruta del archivo encriptado
      final encryptedPath = await _downloadService.getDownloadedVideoPath(
        widget.video.id,
      );
      if (encryptedPath == null) {
        throw Exception('No se encontró el archivo descargado');
      }

      _logger.d('Archivo encriptado encontrado: $encryptedPath');

      // Verificar que el archivo existe
      final encryptedFile = File(encryptedPath);
      if (!await encryptedFile.exists()) {
        throw Exception('El archivo encriptado no existe en: $encryptedPath');
      }

      // Crear archivo temporal para el video desencriptado
      final tempDir = await getTemporaryDirectory();
      final decryptedPath = '${tempDir.path}/${widget.video.id}_decrypted.mp4';
      _decryptedVideoFile = File(decryptedPath);

      _logger.d('Desencriptando video a: $decryptedPath');

      // Desencriptar el video completo en un archivo temporal
      await _decryptVideoToFile(encryptedPath, decryptedPath);

      _logger.success('Video desencriptado exitosamente');

      // Verificar que el archivo desencriptado existe
      if (!await _decryptedVideoFile!.exists()) {
        throw Exception('El archivo desencriptado no se creó correctamente');
      }

      final fileSize = await _decryptedVideoFile!.length();
      _logger.d('Tamaño del archivo desencriptado: ${fileSize} bytes');

      // Inicializar video_player con el archivo desencriptado
      _logger.d('Inicializando VideoPlayerController...');
      _videoController = VideoPlayerController.file(_decryptedVideoFile!);
      await _videoController!.initialize();

      _logger.d('VideoPlayerController inicializado');
      _logger.d('Aspect ratio: ${_videoController!.value.aspectRatio}');
      _logger.d('Duración: ${_videoController!.value.duration}');

      // Cargar última posición
      await _getLastPosition();

      // Crear ChewieController para controles personalizados
      _logger.d('Creando ChewieController...');
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        aspectRatio: _videoController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          _logger.e('Error en Chewie: $errorMessage');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Error reproduciendo video',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      _logger.success('ChewieController creado exitosamente');

      // Escuchar cambios de posición para guardar progreso
      _videoController!.addListener(_onVideoPositionChanged);

      // Escuchar cuando el video termine
      _videoController!.addListener(_onVideoEnded);

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        widget.onVideoReady?.call();
        _logger.success('Reproductor offline inicializado completamente');
      }
    } catch (e, stackTrace) {
      _logger.e('Error inicializando reproductor offline', e, stackTrace);
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });

        // Mensaje más amigable si el error es de desencriptación
        String errorMessage = 'Error inicializando video offline: $e';
        if (e.toString().contains('Invalid or corrupted pad block') ||
            e.toString().contains('Error desencriptando')) {
          errorMessage =
              'El video fue encriptado con un método anterior incompatible. '
              'Por favor, elimina este video descargado y vuelve a descargarlo.';
        }

        _showError(errorMessage);
      }
    }
  }

  Future<void> _decryptVideoToFile(
    String encryptedPath,
    String decryptedPath,
  ) async {
    try {
      _logger.d('Iniciando desencriptación...');

      final decryptedFile = File(decryptedPath);

      // Eliminar archivo si ya existe
      if (await decryptedFile.exists()) {
        await decryptedFile.delete();
        _logger.d('Archivo temporal anterior eliminado');
      }

      final outputStream = decryptedFile.openWrite();
      int chunkCount = 0;
      int totalBytes = 0;

      await for (final chunk in _encryptionService.decryptVideoFileStream(
        encryptedPath,
      )) {
        outputStream.add(chunk);
        chunkCount++;
        totalBytes += chunk.length;

        if (chunkCount % 100 == 0) {
          _logger.d('Chunks procesados: $chunkCount, bytes: $totalBytes');
        }
      }

      await outputStream.close();

      _logger.success(
        'Desencriptación completada: $chunkCount chunks, $totalBytes bytes',
      );
      final fileSize = await decryptedFile.length();
      _logger.d('Tamaño final del archivo: $fileSize bytes');

      // Verificar que el tamaño coincide
      if (fileSize != totalBytes) {
        _logger.w(
          'Advertencia: El tamaño del archivo ($fileSize) no coincide con los bytes escritos ($totalBytes)',
        );
      }

      // Verificar que el archivo tiene la firma MP4 (debe empezar con "ftyp" o "moov")
      final firstBytes = await decryptedFile.openRead(0, 12).first;
      final firstBytesList = firstBytes.toList();

      // Buscar "ftyp" o "moov" en los primeros bytes
      String? signature;
      for (int i = 0; i <= firstBytesList.length - 4; i++) {
        final candidate = String.fromCharCodes(
          firstBytesList.sublist(i, i + 4),
        );
        if (candidate == 'ftyp' || candidate == 'moov') {
          signature = candidate;
          break;
        }
      }

      if (signature != null) {
        _logger.d('Firma del archivo encontrada: $signature');
      } else {
        // Mostrar los primeros bytes en hex para diagnóstico
        final hexSignature = firstBytesList
            .take(16)
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(' ');
        _logger.e('ERROR: El archivo no tiene firma MP4 válida (ftyp/moov)');
        _logger.e('Primeros 16 bytes (hex): $hexSignature');
        _logger.e(
          'Primeros 16 bytes (ascii): ${String.fromCharCodes(firstBytesList.take(16).where((b) => b >= 32 && b <= 126))}',
        );

        // Lanzar error para que el usuario sepa que el archivo está corrupto
        throw Exception(
          'El archivo desencriptado está corrupto. No se encontró la firma MP4 válida. '
          'Esto puede deberse a que el archivo original descargado de YouTube estaba corrupto. '
          'Por favor, elimina este video descargado y vuelve a descargarlo.',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error en desencriptación', e, stackTrace);
      throw Exception('Error desencriptando video: $e');
    }
  }

  Future<void> _getLastPosition() async {
    try {
      if (widget.isFromHistory) {
        final wasCompleted = await _progressService.isVideoCompleted(
          widget.video.videoId,
        );
        _wasAlreadyCompleted = wasCompleted;
        return;
      }

      final lastPosition = await _progressService.getLastPosition(
        widget.video.videoId,
      );

      if (lastPosition > 0 && _videoController != null) {
        await _videoController!.seekTo(Duration(seconds: lastPosition));
        _lastSavedProgress =
            lastPosition / _videoController!.value.duration.inSeconds;
      }
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo última posición', e, stackTrace);
    }
  }

  void _onVideoPositionChanged() {
    if (_videoController == null || !_videoController!.value.isInitialized)
      return;

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    if (duration.inSeconds > 0) {
      final progress = position.inSeconds / duration.inSeconds;

      // Guardar progreso cada 5 segundos
      if ((progress - _lastSavedProgress).abs() >= 0.05 || progress >= 0.95) {
        _saveVideoProgress(position, duration);
        _lastSavedProgress = progress;
      }
    }
  }

  void _onVideoEnded() {
    if (_videoController == null || !_videoController!.value.isInitialized)
      return;

    if (_videoController!.value.position >= _videoController!.value.duration) {
      _handleVideoCompleted();
    }
  }

  Future<void> _saveVideoProgress(Duration position, Duration duration) async {
    try {
      final progress = position.inSeconds / duration.inSeconds;

      await _progressService.saveVideoProgress(
        videoId: widget.video.videoId,
        pauseCount: 0,
        forwardCount: 0,
        lastPosition: position.inSeconds,
        totalDuration: duration.inSeconds,
        progress: progress,
        isCompleted: false,
      );

      // Actualizar el LeccionesProvider con el progreso actualizado
      // El progreso viene como valor entre 0 y 1, necesitamos convertirlo a porcentaje (0-100)
      final progressPercentage = progress * 100.0;
      try {
        final leccionesProvider = Provider.of<LeccionesProvider>(
          context,
          listen: false,
        );
        leccionesProvider.actualizarProgresoVideo(
          widget.video.videoId,
          progressPercentage,
        );
        _logger.d(
          'Progreso actualizado en LeccionesProvider (offline): ${progressPercentage.toStringAsFixed(1)}%',
        );
      } catch (e, stackTrace) {
        // Si no hay provider disponible (puede pasar en algunos contextos), ignorar
        _logger.w(
          'No se pudo actualizar LeccionesProvider (offline)',
          e,
          stackTrace,
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error guardando progreso', e, stackTrace);
    }
  }

  Future<void> _handleVideoCompleted() async {
    if (_wasAlreadyCompleted) return;

    try {
      // markVideoAsCompleted ahora obtiene automáticamente el ID correcto del usuario
      // El primer parámetro (userId) se ignora, pero lo mantenemos por compatibilidad
      await _interactionService.markVideoAsCompleted(
        '', // Se ignora, el servicio obtiene el ID correcto automáticamente
        widget.video.videoId,
      );
      widget.onVideoCompleted?.call();
    } catch (e, stackTrace) {
      _logger.e('Error marcando video como completado', e, stackTrace);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
    _recordingStatusSubscription?.cancel();

    // Desactivar prevención de grabación de pantalla
    ScreenRecordingPreventionService.disableScreenProtection();

    // Eliminar archivo temporal desencriptado (sin await ya que dispose no puede ser async)
    if (_decryptedVideoFile != null) {
      _decryptedVideoFile!
          .delete()
          .then((_) {
            // Archivo eliminado exitosamente
          })
          .catchError((e, stackTrace) {
            _logger.e('Error eliminando archivo temporal', e, stackTrace);
          });
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FD1C7)),
          ),
        ),
      );
    }

    if (_chewieController == null || _videoController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Error inicializando reproductor',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }

  /// Reinicia el video desde el principio
  void _replayVideo() {
    try {
      if (_videoController != null) {
        _videoController!.seekTo(Duration.zero);
        _videoController!.play();
        _logger.d('Reiniciando video offline desde el principio');
      }
    } catch (e, stackTrace) {
      _logger.e('Error reiniciando video offline', e, stackTrace);
    }
  }
}
