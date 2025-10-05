import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/video_bloc.dart';

class VideoListWidget extends StatefulWidget {
  const VideoListWidget({super.key});

  @override
  State<VideoListWidget> createState() => _VideoListWidgetState();
}

class _VideoListWidgetState extends State<VideoListWidget> {
  @override
  void initState() {
    super.initState();
    // Cargar videos al inicializar
    context.read<VideoBloc>().add(const GetAllVideosRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        if (state is VideoLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VideosLoaded) {
          return ListView.builder(
            itemCount: state.videos.length,
            itemBuilder: (context, index) {
              final video = state.videos[index];
              return VideoCard(
                video: video,
                onTap: () => _showVideoDetails(context, video),
                onMarkCompleted: () => _markVideoCompleted(video.id),
              );
            },
          );
        } else if (state is VideoFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar videos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<VideoBloc>().add(
                      const GetAllVideosRequested(),
                    );
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No hay videos disponibles'));
        }
      },
    );
  }

  void _showVideoDetails(BuildContext context, video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lección: ${video.lessonId}'),
            Text('Duración: ${video.duration.inMinutes} minutos'),
            Text('Descripción: ${video.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _markVideoCompleted(video.id);
            },
            child: const Text('Marcar como completado'),
          ),
        ],
      ),
    );
  }

  void _markVideoCompleted(String videoId) {
    // TODO: Obtener el userId del usuario actual
    const userId =
        'current_user_id'; // Temporal hasta implementar autenticación

    context.read<VideoBloc>().add(
      MarkVideoAsCompletedRequested(videoId: videoId, userId: userId),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video marcado como completado'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final dynamic video;
  final VoidCallback onTap;
  final VoidCallback onMarkCompleted;

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    required this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen del video
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/mini_videos/${video.imageName}',
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.video_library),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Información del video
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lección ${video.lessonId}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duración: ${video.duration.inMinutes} min',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Botón de completado
              IconButton(
                onPressed: onMarkCompleted,
                icon: Icon(
                  video.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: video.isCompleted ? Colors.green : Colors.grey,
                ),
                tooltip: video.isCompleted
                    ? 'Completado'
                    : 'Marcar como completado',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
