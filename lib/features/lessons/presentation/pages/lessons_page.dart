import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../bloc/lesson_bloc.dart';
import 'lesson_videos_page.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  @override
  void initState() {
    super.initState();
    // Cargar lecciones al inicializar
    context.read<LessonBloc>().add(const GetAllLessonsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('lessons.title'.tr()),
        backgroundColor: const Color(0xFF03A696),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showStatistics,
            icon: const Icon(Icons.analytics),
            tooltip: 'lessons.statistics'.tr(),
          ),
        ],
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LessonsLoaded) {
            return _buildLessonsList(state.lessons);
          } else if (state is LessonFailure) {
            return _buildErrorWidget(state.message);
          } else {
            return Center(child: Text('lessons.noLessonsAvailable'.tr()));
          }
        },
      ),
    );
  }

  Widget _buildLessonsList(lessons) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return LessonCard(
          lesson: lesson,
          onTap: () => _showLessonDetails(context, lesson),
          onMarkCompleted: () => _markLessonCompleted(lesson.id),
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'lessons.errorLoading'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<LessonBloc>().add(const GetAllLessonsRequested());
            },
            child: Text('lessons.retry'.tr()),
          ),
        ],
      ),
    );
  }

  void _showLessonDetails(BuildContext context, lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'lessons.category'.tr()}: ${lesson.category}'),
            Text(
              '${'lessons.progress'.tr()}: ${(lesson.progress * 100).toInt()}%',
            ),
            Text('${'lessons.videos'.tr()}: ${lesson.videoIds.length}'),
            const SizedBox(height: 8),
            Text(lesson.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showVideosForLesson(lesson.id);
            },
            child: Text('lessons.viewVideos'.tr()),
          ),
        ],
      ),
    );
  }

  void _showVideosForLesson(String lessonId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LessonVideosPage(
          videos: [], // Se cargarán desde el servicio
        ),
      ),
    );
  }

  void _markLessonCompleted(String lessonId) {
    context.read<LessonBloc>().add(
      MarkLessonAsCompletedRequested(lessonId: lessonId),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('lessons.lessonMarkedCompleted'.tr()),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showStatistics() {
    context.read<LessonBloc>().add(const GetUserStatisticsRequested());

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is UserStatisticsLoaded) {
            return AlertDialog(
              title: Text('lessons.statisticsTitle'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'lessons.completedLessons'.tr()}: ${state.statistics['completedLessons'] ?? 0}',
                  ),
                  Text(
                    '${'lessons.completedVideos'.tr()}: ${state.statistics['completedVideos'] ?? 0}',
                  ),
                  Text(
                    '${'lessons.totalTime'.tr()}: ${state.statistics['totalTime'] ?? '0 min'}',
                  ),
                  Text(
                    '${'lessons.overallProgress'.tr()}: ${state.statistics['overallProgress'] ?? 0}%',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('common.close'.tr()),
                ),
              ],
            );
          } else {
            return const AlertDialog(content: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final dynamic lesson;
  final VoidCallback onTap;
  final VoidCallback onMarkCompleted;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
    required this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen de la lección
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/${lesson.imageUrl}',
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.school),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Información de la lección
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.category,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),

                    // Barra de progreso
                    LinearProgressIndicator(
                      value: lesson.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF03A696),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(lesson.progress * 100).toInt()}${'lessons.percentCompleted'.tr()}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Botón de completado
              IconButton(
                onPressed: onMarkCompleted,
                icon: Icon(
                  lesson.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: lesson.isCompleted ? Colors.green : Colors.grey,
                ),
                tooltip: lesson.isCompleted
                    ? 'lessons.completed'.tr()
                    : 'lessons.markCompleted'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
