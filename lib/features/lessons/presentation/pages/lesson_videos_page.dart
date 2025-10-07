import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/video.dart';
import '../../data/services/video_service.dart';
import '../providers/lecciones_provider.dart';

class LessonVideosPage extends StatefulWidget {
  final List<Video> videos;

  const LessonVideosPage({super.key, required this.videos});

  @override
  State<LessonVideosPage> createState() => _LessonVideosPageState();
}

class _LessonVideosPageState extends State<LessonVideosPage> {
  List<Video>? _videos;
  int lastCompletedLesson = 0;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await VideoService.getVideos();
      setState(() {
        _videos = videos;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los videos: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToReproductorVideoHelper(
    int videoId,
    int duracionId,
    String videoURL,
  ) async {
    if (kDebugMode) {
      print("ID del video enviado al reproductor es: $videoId");
    }

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            VideoPlayerPage(videoId: videoId, videoUrl: videoURL),
        transitionsBuilder: (context, animation1, animation2, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation1.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );

    // Verifica si se completó una lección y actualiza lastCompletedLesson
    if (result != null && result is int) {
      setState(() {
        lastCompletedLesson = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avancesProvider = Provider.of<LeccionesProvider>(
      context,
      listen: false,
    );
    avancesProvider.imprimirAvancesMap();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.centerLeft,
            colors: [Color(0xffD9ACF5), Color.fromARGB(255, 122, 231, 211)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildAppBar(),
                SingleChildScrollView(
                  child: _videos != null
                      ? _buildLessons(_videos!)
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Sección de Lecciones de Videos"),
                  content: const Text(
                    "En esta sección se encuentran las lecciones a visualizar.",
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cerrar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: 40.0,
            height: 40.0,
            margin: const EdgeInsets.only(right: 16.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            child: const Icon(Icons.help, size: 24, color: Color(0xffD9ACF5)),
          ),
        ),
      ],
    );
  }

  Widget _buildLessons(List<Video> videos) {
    int previousLessonId = -1;
    int lastCompletedIndex = -1;

    // Encuentra el índice del último video completado
    for (int i = 0; i < videos.length; i++) {
      if (context.read<LeccionesProvider>().isLeccionCompletada(
        videos[i].videoId,
      )) {
        lastCompletedIndex = i;
      } else {
        break;
      }
    }

    return Column(
      children: videos.asMap().entries.map((entry) {
        final index = entry.key;
        final video = entry.value;
        final isOdd = index.isOdd;
        final currentLessonId = video.leccionId;
        final isLastCompleted = index == lastCompletedIndex;

        // Verifica si es necesario mostrar el encabezado
        final showHeader = currentLessonId != previousLessonId;
        previousLessonId = currentLessonId;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              if (showHeader)
                Column(
                  children: [
                    _Title('Lección ${video.leccionId}'),
                    _Subtitle(_getSubtitleForLesson(video.leccionId)),
                  ],
                ),
              Padding(
                padding: EdgeInsets.only(
                  top: isOdd ? 15.0 : 15.0,
                  bottom: isOdd ? 15.0 : 15.0,
                  left: isOdd ? MediaQuery.of(context).size.width * 0.5 : 0.0,
                  right: isOdd ? 0.0 : MediaQuery.of(context).size.width * 0.58,
                ),
                child: _PercentIndicator(
                  context.read<LeccionesProvider>().getProgresoVideo(
                    video.videoId,
                  ),
                  video.imageName,
                  isLastCompleted ? Colors.blue : Colors.blue,
                  video.videoId,
                  video.leccionId,
                  videoURL: video.videoURL,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getSubtitleForLesson(int lessonNumber) {
    switch (lessonNumber) {
      case 1:
        return 'Lactancia materna y sus beneficios';
      case 2:
        return 'Calostro, leche de transición y leche madura';
      case 3:
        return "Cosas en tomar en cuenta al momento de amamantar";
      case 4:
        return "Composición Nutricional de la Leche Materna";
      case 5:
        return '¿Cómo saber que el bebé se alimentó lo suficiente?';
      case 6:
        return "Hitos de peso a vigilar";
      case 7:
        return "Higiene de manos y técnicas de lactancia materna";
      case 8:
        return 'Medicamentos durante la lactancia materna';
      case 9:
        return 'Signos o Complicaciones en la Lactancia';
      case 10:
        return 'Masajes al seno antes de iniciar la lactancia';
      case 11:
        return 'Mi banco de leche en casa y su preservacion';
      case 12:
        return 'Leyes en Panamá que apoyan la lactancia materna';
      case 13:
        return 'Diferencias entre la leche materna y la leche de vaca';
      case 14:
        return 'Mitos de la lactancia materna';
      default:
        return '';
    }
  }

  Widget _Title(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          title,
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _Subtitle(String subtitle) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
        child: Text(
          subtitle,
          style: GoogleFonts.quicksand(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _PercentIndicator(
    double percent,
    String imageName,
    Color color,
    int videoId,
    int leccionId, {
    required String videoURL,
  }) {
    return GestureDetector(
      onTap: () {
        _navigateToReproductorVideoHelper(videoId, leccionId, videoURL);
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Imagen de fondo
              Image.asset(
                'assets/images/$imageName',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.video_library, size: 50),
                  );
                },
              ),
              // Overlay con el indicador de progreso
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 8.0,
                  percent: percent / 100,
                  center: const Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                  progressColor: color,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Página temporal del reproductor de video
class VideoPlayerPage extends StatefulWidget {
  final int videoId;
  final String videoUrl;

  const VideoPlayerPage({
    super.key,
    required this.videoId,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video ${widget.videoId}'),
        backgroundColor: const Color(0xffD9ACF5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 100,
              color: Color(0xffD9ACF5),
            ),
            const SizedBox(height: 20),
            Text(
              'Reproductor de Video',
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Video ID: ${widget.videoId}',
              style: GoogleFonts.quicksand(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Simular que se completó el video
                Navigator.of(context).pop(widget.videoId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD9ACF5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: Text(
                'Marcar como Completado',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
