import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/video.dart';
import '../widgets/advanced_video_player.dart';
import '../../data/services/video_cache_service.dart';
import '../../data/services/video_preload_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video video;
  final String userId;
  final bool isLastVideoInLesson; // Nuevo parámetro
  final bool isFromHistory; // Parámetro para indicar si viene del historial

  const VideoPlayerPage({
    super.key,
    required this.video,
    required this.userId,
    this.isLastVideoInLesson = false, // Por defecto false
    this.isFromHistory = false, // Por defecto false
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final AppLogger _logger = getIt<AppLogger>();
  bool _isVideoPreloaded = false;
  final GlobalKey _playerKey = GlobalKey();
  bool _isNavigatingToNext =
      false; // Flag para saber si estamos navegando al siguiente video

  @override
  void initState() {
    super.initState();
    // Verificar si el video está precargado
    _checkVideoPreloadStatus();
  }

  Future<void> _checkVideoPreloadStatus() async {
    try {
      // Verificar si el video está precargado en cache
      final isPreloaded = await VideoCacheService.isVideoPreloaded(
        widget.video.videoId,
      );

      // Verificar si hay un controlador precargado
      final preloadService = VideoPreloadService();
      final hasPreloadedController = preloadService.isVideoPreloaded(
        widget.video.videoId,
      );

      if (mounted) {
        setState(() {
          _isVideoPreloaded = isPreloaded || hasPreloadedController;
        });

        _logger.d(
          'Video ${widget.video.videoId} precargado: $_isVideoPreloaded',
        );

        // Siempre ir directo al reproductor sin pantalla de carga
        _initializeVideoDirectly();
      }
    } catch (e, stackTrace) {
      _logger.e('Error verificando precarga', e, stackTrace);
      // En caso de error, ir directo al reproductor
      _initializeVideoDirectly();
    }
  }

  Future<void> _initializeVideoDirectly() async {
    // Ir directo al reproductor con auto-rotación
    if (mounted) {
      // Auto-rotar a horizontal para experiencia tipo Netflix
      // Asegurarse de que siempre esté en landscape al inicializar
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      _logger.d('Orientación landscape establecida en initState');
    }
  }

  void _onVideoReady() {
    if (mounted) {
      _logger.d('Video ${widget.video.videoId} listo para reproducir');
    }
  }

  @override
  void dispose() {
    // Solo restaurar orientación vertical si NO estamos navegando al siguiente video
    // Si estamos navegando al siguiente, mantener landscape
    if (!_isNavigatingToNext) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Siempre mostrar directamente el reproductor sin pantalla de carga
    return AdvancedVideoPlayer(
      key: _playerKey,
      video: widget.video,
      onVideoCompleted: () {
        _showCompletionDialog();
      },
      onVideoReady: _onVideoReady,
      isPreloaded: _isVideoPreloaded,
      isLastVideoInLesson: widget.isLastVideoInLesson,
      isFromHistory: widget.isFromHistory,
    );
  }

  Future<void> _showCompletionDialog() async {
    // La trivia ahora se muestra como requisito antes de avanzar, no después del video
    _showFinalCompletionDialog();
  }

  void _showFinalCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Navigator.of(context).pop(true); // Pop "true" (volver)
            }
          },
          child: AlertDialog(
            backgroundColor: const Color(0xFF1F1F1F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'gamification.messages.videoCompleted'.tr(),
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // --- CONTENIDO MODIFICADO ---
            content: Column(
              mainAxisSize: MainAxisSize.min, // Para que la columna se ajuste
              children: [
                Text(
                  'Has completado "${widget.video.title}". ¿Qué deseas hacer?',
                  textAlign: TextAlign.center, // Centrado se ve mejor
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 24), // Espacio antes del botón
                // --- NUEVO BOTÓN CENTRAL ---
                OutlinedButton.icon(
                  icon: const Icon(Icons.replay, size: 20),
                  label: Text(
                    'Volver a ver',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    // Usamos 'null' para indicar "replay"
                    Navigator.of(context).pop(null);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4FD1C7), // Color de acento
                    side: const BorderSide(
                      color: Color(0xFF4FD1C7), // Borde del color de acento
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            // ---------------------------------

            // --- ACCIONES SIMPLIFICADAS ---
            actions: [
              // Acción secundaria: Volver (Siempre visible)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Volver
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(
                    alpha: 0.7,
                  ), // Menos énfasis
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  // Cambia el texto según el contexto
                  widget.isFromHistory ? 'Volver' : 'Volver a lecciones',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),

              // Acción principal: Siguiente (Solo si aplica)
              if (!widget.isFromHistory && !widget.isLastVideoInLesson)
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    'Reproducir siguiente',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Reproducir siguiente
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FD1C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ).then((result) async {
      // Manejar el resultado del diálogo
      // 'result' puede ser:
      // true: Volver a lecciones / Volver
      // false: Reproducir siguiente
      // null: Volver a ver (reiniciar video)

      if (!mounted) return;

      if (result == true) {
        // Volver a la pantalla anterior (lecciones o historial)
        // Restaurar orientación a portrait antes de volver
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else if (result == false) {
        // Reproducir siguiente video: mantener landscape y retornar false
        // para que lesson_videos_page lo maneje
        _isNavigatingToNext = true; // Marcar que estamos navegando al siguiente

        // Asegurar que la orientación landscape se mantenga
        // Hacer esto ANTES de hacer pop para evitar cualquier cambio
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);

        // Pequeño delay para asegurar que la orientación se establezca antes del pop
        await Future.delayed(const Duration(milliseconds: 50));

        if (mounted) {
          Navigator.of(context).pop(false);
        }
      } else if (result == null) {
        // Reiniciar el video actual
        _replayVideo();
      }
    });
  }

  /// Reinicia el video actual desde el principio
  void _replayVideo() {
    try {
      // Usar el método estático de AdvancedVideoPlayer para reiniciar
      AdvancedVideoPlayer.replayVideo(_playerKey);
      _logger.d('Video reiniciado desde el principio');
    } catch (e, stackTrace) {
      _logger.e('Error reiniciando video', e, stackTrace);
    }
  }
}
