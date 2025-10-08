import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/video.dart';
import '../../data/services/video_service.dart';
import '../providers/lecciones_provider.dart';
import '../providers/video_images_provider.dart';
import '../../../videos/presentation/pages/video_player_page.dart';
import '../../../videos/domain/entities/video.dart' as video_entity;

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
    _initializeProviders();
    _loadVideos();
  }

  Future<void> _initializeProviders() async {
    // Inicializar el provider de imágenes de videos
    final videoImagesProvider = Provider.of<VideoImagesProvider>(
      context,
      listen: false,
    );
    await videoImagesProvider.initialize();
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

    // Obtener el nombre de imagen correcto usando el Provider
    final videoImagesProvider = Provider.of<VideoImagesProvider>(
      context,
      listen: false,
    );
    final imageName = videoImagesProvider.getImageNameForVideo(videoId);

    if (kDebugMode) {
      print("📸 Imagen seleccionada para video $videoId: $imageName");
    }

    // Convertir Video de lessons a Video de videos
    final video = video_entity.Video(
      id: videoId.toString(),
      title: 'Video $videoId',
      description: 'Lección de lactancia materna',
      videoUrl: videoURL,
      imageUrl: '',
      imageName: imageName, // Usar la imagen correcta del Provider
      videoId: videoId,
      order: videoId,
      duration: const Duration(minutes: 5), // Duración por defecto
      lessonId: duracionId,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => VideoPlayerPage(
          video: video,
          userId: 'current_user', // TODO: Obtener ID del usuario actual
        ),
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
    if (result != null && result is bool && result) {
      setState(() {
        lastCompletedLesson = videoId;
      });
      // Actualizar el provider
      context.read<LeccionesProvider>().marcarLeccionCompletada(videoId);
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C5F5D), // Azul teal oscuro
              Color(0xFF1A365D), // Azul marino oscuro
              Color(0xFF4FD1C7), // Verde azulado vibrante
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con navegación
              _buildHeader(),

              // Contenido principal - Camino de lecciones
              Expanded(
                child: _videos == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : _buildLessonPath(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const Expanded(
            child: Text(
              'Camino de Lactancia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Camino de Lactancia"),
                    content: const Text(
                      "Sigue el camino paso a paso para aprender sobre lactancia materna.",
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.help, size: 24, color: Color(0xFF2C5F5D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonPath() {
    if (_videos == null || _videos!.isEmpty) {
      return const Center(
        child: Text(
          'No hay lecciones disponibles',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    // Agrupar videos por lección
    Map<int, List<Video>> lessonsMap = {};
    for (var video in _videos!) {
      lessonsMap.putIfAbsent(video.leccionId, () => []).add(video);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: lessonsMap.entries.map((entry) {
          final lessonId = entry.key;
          final videos = entry.value;
          return _buildLessonSection(lessonId, videos);
        }).toList(),
      ),
    );
  }

  Widget _buildLessonSection(int lessonId, List<Video> videos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la lección
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lección $lessonId',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _getSubtitleForLesson(lessonId),
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Camino de videos
          _buildVideoPath(videos),
        ],
      ),
    );
  }

  Widget _buildVideoPath(List<Video> videos) {
    return CustomPaint(
      painter: LessonPathPainter(videos.length),
      child: Column(
        children: videos.asMap().entries.map((entry) {
          final index = entry.key;
          final video = entry.value;

          return Column(
            children: [
              // Nodo del video con posición personalizada
              Container(
                height: 100,
                child: Center(child: _buildVideoNode(video, index)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVideoNode(Video video, int index) {
    final progress = context.watch<LeccionesProvider>().getProgresoVideo(
      video.videoId,
    );
    final isCompleted = progress >= 100.0;

    // Lógica de disponibilidad: solo el primer video de la primera lección está disponible inicialmente
    // Después, solo se habilita el siguiente video cuando el anterior está completado
    final isAvailable = _isVideoAvailable(video, index);

    // Tamaño dinámico del nodo
    final nodeSize = isCompleted
        ? 90.0
        : isAvailable
        ? 85.0
        : 75.0;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              _navigateToReproductorVideoHelper(
                video.videoId,
                video.leccionId,
                video.videoURL,
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: nodeSize,
        height: nodeSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted
              ? Colors.green
              : isAvailable
              ? Colors.white
              : Colors.grey.withValues(alpha: 0.3),
          border: Border.all(
            color: isCompleted
                ? Colors.green
                : isAvailable
                ? const Color(0xFF4FD1C7)
                : Colors.grey,
            width: isCompleted ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? Colors.green.withValues(alpha: 0.4)
                  : isAvailable
                  ? const Color(0xFF4FD1C7).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isCompleted ? 12 : 8,
              spreadRadius: isCompleted ? 2 : 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Imagen del video como fondo
            if (isAvailable || isCompleted)
              Positioned.fill(
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/lecciones_camino/${video.pathImageName}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForVideo(video),
                          color: Colors.grey,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Overlay verde con checkmark para videos completados
            if (isCompleted)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.green.withValues(alpha: 0.9),
                        Colors.green.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.check, color: Colors.white, size: 35),
                  ),
                ),
              ),

            // Icono de candado para videos bloqueados
            if (!isAvailable && !isCompleted)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  child: const Icon(Icons.lock, color: Colors.grey, size: 25),
                ),
              ),

            // CircularProgressIndicator que rodea la imagen
            if (isAvailable && !isCompleted && progress > 0)
              Positioned.fill(
                child: Stack(
                  children: [
                    // CircularProgressIndicator como borde
                    Center(
                      child: SizedBox(
                        width: nodeSize,
                        height: nodeSize,
                        child: CircularProgressIndicator(
                          value: progress / 100.0,
                          strokeWidth: 6,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color.fromARGB(
                              255,
                              190,
                              104,
                              244,
                            ), // Color primario de la app
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Efecto de pulso para videos disponibles
            if (isAvailable && !isCompleted)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4FD1C7).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isVideoAvailable(Video video, int index) {
    if (_videos == null) return false;

    // Solo el primer video de la primera lección está disponible inicialmente
    if (video.leccionId == 1 && index == 0) {
      return true;
    }

    // Para videos posteriores, verificar si el video anterior está completado
    if (index > 0) {
      final previousVideo = _videos![index - 1];
      return context.watch<LeccionesProvider>().isLeccionCompletada(
        previousVideo.videoId,
      );
    }

    return false;
  }

  IconData _getIconForVideo(Video video) {
    // Asignar iconos diferentes según el tipo de contenido
    switch (video.videoId % 4) {
      case 0:
        return Icons.play_circle_filled;
      case 1:
        return Icons.video_library;
      case 2:
        return Icons.school;
      case 3:
        return Icons.quiz;
      default:
        return Icons.play_circle_filled;
    }
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
}

// Pintor personalizado para crear el camino curvo y dinámico
class LessonPathPainter extends CustomPainter {
  final int nodeCount;

  LessonPathPainter(this.nodeCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final nodeSpacing = 100.0; // Espaciado entre nodos

    // Dibujar el camino curvo
    for (int i = 0; i < nodeCount - 1; i++) {
      final startY = (i * nodeSpacing) + 50;
      final endY = ((i + 1) * nodeSpacing) + 50;

      // Crear curva suave entre nodos
      final controlPoint1 = Offset(
        centerX + (i % 2 == 0 ? 20 : -20),
        startY + 30,
      );
      final controlPoint2 = Offset(
        centerX + (i % 2 == 0 ? -20 : 20),
        endY - 30,
      );

      final path = Path();
      path.moveTo(centerX, startY);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        centerX,
        endY,
      );

      // Dibujar sombra primero
      canvas.drawPath(path, shadowPaint);
      // Dibujar línea principal
      canvas.drawPath(path, paint);

      // Agregar puntos decorativos en la curva
      _drawDecorativeDots(canvas, path, i);
    }
  }

  void _drawDecorativeDots(Canvas canvas, Path path, int segmentIndex) {
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Calcular puntos a lo largo de la curva
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final length = pathMetric.length;
      final dotCount = 3;

      for (int i = 1; i < dotCount; i++) {
        final distance = (length * i) / dotCount;
        final tangent = pathMetric.getTangentForOffset(distance);

        if (tangent != null) {
          canvas.drawCircle(tangent.position, 2.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
