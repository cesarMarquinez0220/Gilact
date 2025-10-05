import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../domain/entities/video.dart';
import '../../domain/entities/video_progress.dart';
import '../../domain/entities/video_session.dart';
import '../bloc/video_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video video;
  final String userId;

  const VideoPlayerPage({super.key, required this.video, required this.userId});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  late VideoProgress _currentProgress;
  bool _isInitialized = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // Extraer ID del video de YouTube de la URL
    final videoId = YoutubePlayer.convertUrlToId(widget.video.url) ?? '';

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: false,
        forceHD: true,
        enableCaption: true,
        showLiveFullscreenButton: true,
      ),
    );

    // Cargar progreso del video
    context.read<VideoBloc>().add(
      GetVideoProgressRequested(
        videoId: widget.video.id,
        userId: widget.userId,
      ),
    );

    // Crear nueva sesión de video
    final session = VideoSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: widget.video.id,
      userId: widget.userId,
      startTime: DateTime.now(),
      totalWatchTime: Duration.zero,
      currentPosition: Duration.zero,
      isCompleted: false,
      metadata: {},
    );

    context.read<VideoBloc>().add(
      CreateVideoSessionRequested(session: session),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.video.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showVideoInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: BlocListener<VideoBloc, VideoState>(
        listener: (context, state) {
          if (state is VideoProgressLoaded) {
            _currentProgress = state.progress;
            _isInitialized = true;
            _seekToLastPosition();
          } else if (state is VideoProgressUpdated) {
            _currentProgress = state.progress;
          } else if (state is VideoCompleted) {
            _isCompleted = true;
            _showCompletionDialog();
          } else if (state is VideoFailure) {
            _showErrorSnackBar(state.message);
          }
        },
        child: Column(
          children: [
            // Reproductor de YouTube
            Expanded(
              flex: 3,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primary,
                onReady: () {
                  _isInitialized = true;
                  _seekToLastPosition();
                },
                onEnded: (data) {
                  _onVideoEnded();
                },
              ),
            ),

            // Información del video
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del video
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Duración y progreso
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(_controller.metadata.duration),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        if (_isInitialized)
                          Text(
                            '${(_currentProgress.progressPercentage * 100).toInt()}% completado',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Barra de progreso
                    if (_isInitialized)
                      LinearProgressIndicator(
                        value: _currentProgress.progressPercentage,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isCompleted ? null : _markAsCompleted,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              _isCompleted
                                  ? 'Completado'
                                  : 'Marcar como Completado',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCompleted
                                  ? AppColors.success
                                  : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showVideoStatistics,
                            icon: const Icon(Icons.analytics),
                            label: const Text('Estadísticas'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Información adicional
                    if (_isInitialized) ...[
                      Row(
                        children: [
                          _buildStatItem(
                            Icons.play_circle,
                            'Reproducciones',
                            _currentProgress.watchCount.toString(),
                          ),
                          const SizedBox(width: 16),
                          _buildStatItem(
                            Icons.schedule,
                            'Última vez',
                            _formatDate(_currentProgress.lastWatchedAt),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _seekToLastPosition() {
    if (_isInitialized && _currentProgress.currentPosition.inSeconds > 0) {
      _controller.seekTo(_currentProgress.currentPosition);
    }
  }

  void _onVideoEnded() {
    // Marcar video como completado
    context.read<VideoBloc>().add(
      MarkVideoAsCompletedRequested(
        videoId: widget.video.id,
        userId: widget.userId,
      ),
    );

    // Actualizar progreso
    final completedProgress = _currentProgress.copyWith(
      progressPercentage: 1.0,
      isCompleted: true,
      currentPosition: _controller.metadata.duration,
      lastWatchedAt: DateTime.now(),
    );

    context.read<VideoBloc>().add(
      UpdateVideoProgressRequested(progress: completedProgress),
    );
  }

  void _markAsCompleted() {
    context.read<VideoBloc>().add(
      MarkVideoAsCompletedRequested(
        videoId: widget.video.id,
        userId: widget.userId,
      ),
    );
  }

  void _showVideoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.video.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duración: ${_formatDuration(_controller.metadata.duration)}'),
            const SizedBox(height: 8),
            Text('Lección: ${widget.video.lessonId}'),
            const SizedBox(height: 8),
            Text('URL: ${widget.video.url}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showVideoStatistics() {
    context.read<VideoBloc>().add(
      GetVideoStatisticsRequested(
        videoId: widget.video.id,
        userId: widget.userId,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          if (state is VideoStatisticsLoaded) {
            final stats = state.statistics;
            return AlertDialog(
              title: const Text('Estadísticas del Video'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vistas totales: ${stats.totalViews}'),
                  Text('Vistas únicas: ${stats.uniqueViews}'),
                  Text(
                    'Tiempo total: ${_formatDuration(stats.totalWatchTime)}',
                  ),
                  Text(
                    'Tiempo promedio: ${_formatDuration(stats.averageWatchTime)}',
                  ),
                  Text(
                    'Tasa de finalización: ${(stats.completionRate * 100).toInt()}%',
                  ),
                  Text('Pausas totales: ${stats.pauseCount}'),
                  Text('Saltos totales: ${stats.seekCount}'),
                  Text('Primera vez: ${_formatDate(stats.firstWatchedAt)}'),
                  Text('Última vez: ${_formatDate(stats.lastWatchedAt)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
          return const AlertDialog(content: CircularProgressIndicator());
        },
      ),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
