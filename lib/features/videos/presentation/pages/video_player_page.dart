import 'package:flutter/material.dart';

import '../../domain/entities/video.dart';
import '../widgets/advanced_video_player.dart';
import '../widgets/video_loading_widget.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video video;
  final String userId;

  const VideoPlayerPage({super.key, required this.video, required this.userId});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool _isLoading = true;
  bool _isVideoReady = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Iniciar el proceso de carga del video
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Tiempo mínimo de carga para UX (1 segundo)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _hasInitialized = true;
      });

      // Timeout de seguridad: si después de 10 segundos no se ha recibido onVideoReady,
      // forzar la transición
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isLoading) {
          print('Timeout: Forzando transición a video player');
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _onVideoReady() {
    if (mounted) {
      setState(() {
        _isVideoReady = true;
      });

      // Esperar un poco más para asegurar transición suave
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Stack(
        children: [
          // Pantalla de carga visible
          VideoLoadingWidget(
            videoTitle: widget.video.title,
            thumbnailUrl: 'assets/mini_videos/${widget.video.imageName}',
            onVideoReady: _isVideoReady,
          ),

          // Reproductor inicializándose en segundo plano (invisible)
          if (_hasInitialized)
            Positioned(
              left: -1000, // Fuera de la pantalla
              child: SizedBox(
                width: 1,
                height: 1,
                child: AdvancedVideoPlayer(
                  video: widget.video,
                  onVideoCompleted: () {
                    _showCompletionDialog();
                  },
                  onVideoReady: _onVideoReady,
                ),
              ),
            ),
        ],
      );
    }

    return AdvancedVideoPlayer(
      video: widget.video,
      onVideoCompleted: () {
        _showCompletionDialog();
      },
      onVideoReady: _onVideoReady,
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Video Completado!'),
        content: const Text('Has completado este video exitosamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
