import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../bloc/lesson_bloc.dart';
import 'lesson_videos_page.dart';
import '../../../../core/utils/responsive_helper.dart';

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
      body: SafeArea(
        child: BlocBuilder<LessonBloc, LessonState>(
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
      ),
    );
  }

  Widget _buildLessonsList(lessons) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: lessons.length,
      // Optimización: cacheExtent reduce reconstrucciones durante scroll
      cacheExtent: 500, // Cache 500px fuera del viewport
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
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(context, 64.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: iconSize, color: Colors.red[300]),
            SizedBox(height: spacing * 1.5),
            Text(
              'lessons.errorLoading'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20.0),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing * 0.75),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    14.0,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: spacing * 1.5),
            ElevatedButton(
              onPressed: () {
                context.read<LessonBloc>().add(const GetAllLessonsRequested());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  0,
                  ResponsiveHelper.getResponsiveButtonHeight(context),
                ),
                padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
              ),
              child: Text('lessons.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showLessonDetails(BuildContext context, lesson) {
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          lesson.title,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18.0),
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: ResponsiveHelper.isTablet(context)
                ? 500.0
                : MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'lessons.category'.tr()}: ${lesson.category}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14.0,
                    ),
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  '${'lessons.progress'.tr()}: ${(lesson.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14.0,
                    ),
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  '${'lessons.videos'.tr()}: ${lesson.videoIds.length}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14.0,
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is UserStatisticsLoaded) {
            return AlertDialog(
              title: Text(
                'lessons.statisticsTitle'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    18.0,
                  ),
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: ResponsiveHelper.isTablet(context)
                      ? 500.0
                      : MediaQuery.of(context).size.width * 0.9,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'lessons.completedLessons'.tr()}: ${state.statistics['completedLessons'] ?? 0}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            14.0,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        '${'lessons.completedVideos'.tr()}: ${state.statistics['completedVideos'] ?? 0}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            14.0,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        '${'lessons.totalTime'.tr()}: ${state.statistics['totalTime'] ?? '0 min'}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            14.0,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        '${'lessons.overallProgress'.tr()}: ${state.statistics['overallProgress'] ?? 0}%',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
    final isSmallScreen =
        ResponsiveHelper.isExtraSmall(context) ||
        ResponsiveHelper.isSmall(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);
    final cardPadding = isSmallScreen ? padding * 0.75 : padding;
    // Usar padding para borderRadius responsive
    final borderRadius = padding * 0.5;

    return Card(
      margin: EdgeInsets.only(bottom: spacing * 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  // Imagen de la lección con tamaño proporcional
                  FractionallySizedBox(
                    widthFactor: 0.2,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final devicePixelRatio = MediaQuery.of(
                              context,
                            ).devicePixelRatio;
                            final cacheWidth =
                                (constraints.maxWidth * devicePixelRatio)
                                    .round();
                            final cacheHeight =
                                (constraints.maxHeight * devicePixelRatio)
                                    .round();
                            return Image.asset(
                              'assets/images/${lesson.imageUrl}',
                              fit: BoxFit.cover,
                              cacheWidth: cacheWidth,
                              cacheHeight: cacheHeight,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.school,
                                    size:
                                        ResponsiveHelper.getResponsiveIconSize(
                                          context,
                                          24.0,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: spacing),

                  // Información de la lección
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              isSmallScreen ? 14.0 : 16.0,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: spacing * 0.25),
                        Text(
                          lesson.category,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              isSmallScreen ? 12.0 : 14.0,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: spacing * 0.5),

                        // Barra de progreso
                        LinearProgressIndicator(
                          value: lesson.progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF03A696),
                          ),
                          minHeight: isSmallScreen ? 3 : 4,
                        ),
                        SizedBox(height: spacing * 0.25),
                        Text(
                          '${(lesson.progress * 100).toInt()}${'lessons.percentCompleted'.tr()}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              isSmallScreen ? 10.0 : 12.0,
                            ),
                            color: Colors.grey[500],
                          ),
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
                      size: ResponsiveHelper.getResponsiveIconSize(
                        context,
                        24.0,
                      ),
                    ),
                    tooltip: lesson.isCompleted
                        ? 'lessons.completed'.tr()
                        : 'lessons.markCompleted'.tr(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
