import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../lessons/presentation/providers/lecciones_provider.dart';
import '../../../lessons/presentation/providers/video_images_provider.dart';
import '../../../lessons/data/services/video_service.dart';
import '../../../lessons/domain/entities/video.dart';
import '../pages/video_player_page.dart';
import '../../../videos/domain/entities/video.dart' as video_entity;
import '../../../videos/data/services/video_interaction_service.dart';
import '../../../videos/presentation/bloc/video_download_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../videos/data/datasources/video_offline_local_data_source.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

class UserVideosPage extends StatefulWidget {
  const UserVideosPage({super.key});

  @override
  State<UserVideosPage> createState() => _UserVideosPageState();
}

class _UserVideosPageState extends State<UserVideosPage> {
  int lastCompletedLesson = 0;
  List<Video> _videos = [];
  List<int> _completedVideos = [];
  bool _isLoading = true;
  String? _error;
  // Mapeo de videoIdNumber (int) a videoId (String) para modo offline
  final Map<int, String> _videoIdMap = {};

  final VideoInteractionService _interactionService =
      GetIt.instance<VideoInteractionService>();
  final ConnectivityService _connectivityService = ConnectivityService();
  final VideoOfflineLocalDataSource _offlineDataSource =
      GetIt.instance<VideoOfflineLocalDataSource>();

  @override
  void initState() {
    super.initState();
    _loadVideosAndProgress();
  }

  Future<void> _loadVideosAndProgress() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Verificar conectividad
      final isConnected = await _connectivityService.isConnected();

      if (!isConnected) {
        // Modo offline: cargar videos descargados desde la base de datos local
        if (kDebugMode) {
          print('📴 Modo offline: Cargando videos descargados...');
        }

        final offlineVideos = await _offlineDataSource.getAllOfflineVideos();

        // Convertir OfflineVideoModel a Video (de lessons)
        // Necesitamos guardar el videoId original (String) para usarlo después
        final videos = offlineVideos.map((offlineVideo) {
          // Crear un Video temporal con el videoIdNumber, pero guardar el videoId original
          final video = Video(
            videoId: offlineVideo.videoIdNumber,
            leccionId: offlineVideo.lessonId,
            videoURL: '', // No hay URL en modo offline
            imageName: offlineVideo.imageName,
            pathImageName: offlineVideo.imageName,
            title: offlineVideo.title,
            description: offlineVideo.description,
            duration: offlineVideo.duration,
            progress: 0.0,
            isCompleted: false,
          );
          // Guardar el videoId original (String) en un campo temporal
          // Usaremos esto en _convertToVideoEntity
          return video;
        }).toList();

        // Guardar el mapeo de videoIdNumber a videoId (String) para usarlo después
        _videoIdMap.clear();
        for (final offlineVideo in offlineVideos) {
          _videoIdMap[offlineVideo.videoIdNumber] = offlineVideo.videoId;
        }

        // En modo offline, todos los videos descargados están "completados" (disponibles)
        final completedVideos = videos.map((v) => v.videoId).toList();

        // Obtener última lección completada desde el provider (puede estar en cache)
        int ultimaLeccion = 0;
        try {
          final leccionesProvider = Provider.of<LeccionesProvider>(
            context,
            listen: false,
          );
          ultimaLeccion = leccionesProvider.ultimaLeccionCompletada;
        } catch (e) {
          // Si no hay provider, usar la última lección de los videos descargados
          if (videos.isNotEmpty) {
            ultimaLeccion = videos
                .map((v) => v.leccionId)
                .reduce((a, b) => a > b ? a : b);
          }
        }

        setState(() {
          _videos = videos;
          _completedVideos = completedVideos;
          lastCompletedLesson = ultimaLeccion;
          _isLoading = false;
        });

        if (kDebugMode) {
          print('📊 Historial offline cargado:');
          print('📹 Total videos descargados: ${_videos.length}');
          print('✅ Videos disponibles: $_completedVideos');
          print('🎯 Última lección: $lastCompletedLesson');
        }
        return;
      }

      // Modo online: cargar desde Firestore
      // Obtener usuario actual
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Usuario no autenticado';
          _isLoading = false;
        });
        return;
      }

      // Cargar videos desde el servicio
      final videos = await VideoService.getVideos();

      // Obtener progreso de videos completados
      // getCompletedVideos ahora obtiene automáticamente el ID correcto del documento del usuario
      // El parámetro userId se ignora, pero lo mantenemos por compatibilidad
      final completedVideos = await _interactionService.getCompletedVideos(
        '', // Se ignora, el servicio obtiene el ID correcto automáticamente
      );

      // Obtener última lección completada desde el provider
      final leccionesProvider = Provider.of<LeccionesProvider>(
        context,
        listen: false,
      );
      final ultimaLeccion = leccionesProvider.ultimaLeccionCompletada;

      setState(() {
        _videos = videos;
        _completedVideos = completedVideos;
        lastCompletedLesson = ultimaLeccion;
        _isLoading = false;
      });

      // Log para debugging
      if (kDebugMode) {
        print('📊 Historial cargado:');
        print('📹 Total videos: ${_videos.length}');
        print('✅ Videos completados: $_completedVideos');
        print('🎯 Última lección completada: $lastCompletedLesson');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cargando videos: $e');
      }
      setState(() {
        _error = 'Error al cargar videos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VideoDownloadBloc>(),
      child: BlocListener<VideoDownloadBloc, VideoDownloadState>(
        listener: (context, state) {
          if (state is VideoDownloadCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Video descargado exitosamente',
                  style: GoogleFonts.quicksand(),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is VideoDownloadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${state.message}',
                  style: GoogleFonts.quicksand(),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is VideoDownloadDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Video eliminado',
                  style: GoogleFonts.quicksand(),
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(),
          body: _isLoading
              ? _buildLoadingState()
              : _error != null
              ? _buildErrorState()
              : _buildContent(),
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
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5F5D), // Azul teal oscuro (secundario)
            Color(0xFF1A365D), // Azul marino oscuro (primario)
            Color(0xFF4FD1C7), // Verde azulado medio vibrante (primario)
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando videos...',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5F5D), // Azul teal oscuro (secundario)
            Color(0xFF1A365D), // Azul marino oscuro (primario)
            Color(0xFF4FD1C7), // Verde azulado medio vibrante (primario)
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Error desconocido',
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVideosAndProgress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A365D),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5F5D), // Azul teal oscuro (secundario)
            Color(0xFF1A365D), // Azul marino oscuro (primario)
            Color(0xFF4FD1C7), // Verde azulado medio vibrante (primario)
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Agregar padding para el AppBar (reducido)
          SizedBox(
            height: MediaQuery.of(context).padding.top + kToolbarHeight - 20,
          ),
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: _buildVideosList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Última lección completada: $lastCompletedLesson',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalVideos = _videos.length;
    // Contar videos completados usando la función _isVideoCompleted
    final completedCount = _videos
        .where((video) => _isVideoCompleted(video.videoId))
        .length;
    final progress = totalVideos > 0 ? completedCount / totalVideos : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso General',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${completedCount}/${totalVideos}',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% completado',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosList() {
    if (_videos.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          final isCompleted = _isVideoCompleted(video.videoId);
          // Solo desbloquear videos que están completados (estaCompletado: true)
          final isUnlocked = isCompleted;

          return _buildVideoCard(video, isCompleted, isUnlocked);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay videos disponibles',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los videos aparecerán aquí cuando estén disponibles',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Video video, bool isCompleted, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isUnlocked ? () => _navigateToVideoPlayer(video) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildVideoThumbnail(video, isCompleted, isUnlocked),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVideoInfo(video, isCompleted, isUnlocked),
                ),
                _buildVideoAction(video, isCompleted, isUnlocked),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(Video video, bool isCompleted, bool isUnlocked) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage('assets/mini_videos/${video.imageName}'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (!isUnlocked)
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.6),
            ),
            child: const Center(
              child: Icon(Icons.lock, color: Colors.white, size: 24),
            ),
          ),
        if (isCompleted)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoInfo(Video video, bool isCompleted, bool isUnlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          video.title,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Video ${video.videoId}',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.play_circle_outline,
              size: 16,
              color: isCompleted ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              isCompleted ? 'Completado' : 'Pendiente',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: isCompleted
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoAction(Video video, bool isCompleted, bool isUnlocked) {
    if (!isUnlocked) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock, color: AppColors.textSecondary, size: 20),
      );
    }

    return BlocBuilder<VideoDownloadBloc, VideoDownloadState>(
      builder: (context, downloadState) {
        // Convertir Video de lessons a video_entity.Video
        final videoEntity = _convertToVideoEntity(video);
        final videoId = videoEntity.id;

        // Verificar estado de descarga
        bool isDownloaded = false;
        bool isDownloading = false;
        double downloadProgress = 0.0;

        if (downloadState is VideoDownloadStatusChecked &&
            downloadState.videoId == videoId) {
          isDownloaded = downloadState.isDownloaded;
        } else if (downloadState is VideoDownloadInProgress &&
            downloadState.videoId == videoId) {
          isDownloading = true;
        } else if (downloadState is VideoDownloadProgress &&
            downloadState.videoId == videoId) {
          isDownloading = true;
          downloadProgress = downloadState.progress;
        } else if (downloadState is VideoDownloadCompleted &&
            downloadState.videoId == videoId) {
          isDownloaded = true;
        }

        // Verificar estado inicial
        if (!isDownloaded && !isDownloading) {
          context.read<VideoDownloadBloc>().add(
            CheckVideoDownloadStatus(videoId),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de descarga
            GestureDetector(
              onTap: () {
                if (isDownloaded) {
                  // Eliminar descarga
                  _showDeleteDownloadDialog(context, videoEntity);
                } else if (!isDownloading) {
                  // Iniciar descarga
                  context.read<VideoDownloadBloc>().add(
                    DownloadVideoRequested(videoEntity),
                  );
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDownloaded
                      ? AppColors.success.withOpacity(0.2)
                      : isDownloading
                      ? AppColors.warning.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: isDownloading
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: downloadProgress > 0
                                  ? downloadProgress
                                  : null,
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        isDownloaded ? Icons.download_done : Icons.download,
                        color: isDownloaded
                            ? AppColors.success
                            : AppColors.primary,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de reproducir
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FD1C7), Color(0xFF1A365D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FD1C7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }

  video_entity.Video _convertToVideoEntity(Video video) {
    // Obtener el nombre de imagen correcto
    String imageName = video.imageName;
    try {
      final videoImagesProvider = Provider.of<VideoImagesProvider>(
        context,
        listen: false,
      );
      imageName = videoImagesProvider.getImageNameForVideo(video.videoId);
    } catch (e) {
      // Si no hay provider (modo offline), usar el imageName del video
      imageName = video.imageName;
    }

    // En modo offline, usar el videoId original (String) del mapeo
    // Si no está en el mapeo, usar el videoIdNumber como string (modo online)
    final videoIdString =
        _videoIdMap[video.videoId] ?? video.videoId.toString();

    return video_entity.Video(
      id: videoIdString, // Usar el videoId original (String) en modo offline
      title: video.title,
      videoUrl: video.videoURL,
      imageUrl: video.imageName,
      imageName: imageName,
      lessonId: video.leccionId,
      videoId: video.videoId,
      description: video.description,
      duration: video.duration,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: _isVideoCompleted(video.videoId),
      order: video.videoId,
    );
  }

  void _showDeleteDownloadDialog(
    BuildContext context,
    video_entity.Video video,
  ) {
    // Obtener el bloc antes de mostrar el diálogo para evitar problemas de contexto
    final downloadBloc = context.read<VideoDownloadBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Eliminar descarga',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar la descarga de "${video.title}"?',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: GoogleFonts.quicksand(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              downloadBloc.add(DeleteDownloadedVideoRequested(video.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Eliminar',
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  bool _isVideoCompleted(int videoId) {
    final isCompleted = _completedVideos.contains(videoId);
    if (isCompleted) {
      print('✅ Video $videoId está completado');
    }
    return isCompleted;
  }

  Future<void> _navigateToVideoPlayer(Video video) async {
    try {
      // Obtener el nombre de imagen correcto usando el Provider
      String imageName;
      try {
        final videoImagesProvider = Provider.of<VideoImagesProvider>(
          context,
          listen: false,
        );
        imageName = videoImagesProvider.getImageNameForVideo(video.videoId);
      } catch (e) {
        // Si no hay provider (modo offline), usar el imageName del video
        imageName = video.imageName;
      }

      // Convertir Video de lessons a Video de videos
      final videoEntity = _convertToVideoEntity(video);

      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => VideoPlayerPage(
            video: videoEntity,
            userId: FirebaseAuth.instance.currentUser?.uid ?? 'current_user',
            isFromHistory: true, // Indicar que viene del historial
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

      // Si se completó el video, recargar la lista
      if (result != null && result is bool && result) {
        await _loadVideosAndProgress();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reproducir video: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
