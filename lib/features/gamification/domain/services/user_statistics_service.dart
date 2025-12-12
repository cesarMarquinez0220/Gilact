import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/app_logger.dart';
import '../../../lactation/data/services/lactation_service.dart';
import '../../../lactation/data/datasources/lactation_database.dart';
import '../../../lessons/domain/repositories/lesson_repository.dart';
import '../../../lactation/data/datasources/baby_weight_offline_local_data_source.dart';
import '../../../lactation/data/datasources/sleep_offline_local_data_source.dart';
import '../repositories/gamification_repository.dart';
import '../entities/xp_transaction.dart';
import '../../../lessons/data/services/video_service.dart';

/// Servicio para obtener estadísticas reales del usuario
/// Utilizado para mejorar la detección de logros
@injectable
class UserStatisticsService {
  final LessonRepository _lessonRepository;
  final BabyWeightOfflineLocalDataSource _weightDataSource;
  final SleepOfflineLocalDataSource _sleepDataSource;
  final GamificationRepository _gamificationRepository;

  UserStatisticsService({
    required LessonRepository lessonRepository,
    required BabyWeightOfflineLocalDataSource weightDataSource,
    required SleepOfflineLocalDataSource sleepDataSource,
    required GamificationRepository gamificationRepository,
  }) : _lessonRepository = lessonRepository,
       _weightDataSource = weightDataSource,
       _sleepDataSource = sleepDataSource,
       _gamificationRepository = gamificationRepository;

  /// Obtiene LactationService de forma lazy para evitar dependencia circular
  LactationService get _lactationService => getIt<LactationService>();

  /// Obtiene LactationDatabase directamente para acceso optimizado
  final LactationDatabase _lactationDatabase = LactationDatabase();

  /// Obtiene todas las estadísticas necesarias para la detección de logros
  /// Optimizado para usar getAllRecords() en lugar de múltiples queries
  Future<UserStatistics> getUserStatistics(String userId) async {
    try {
      // OPTIMIZACIÓN: Obtener todos los registros de una vez desde la base de datos local
      // Esto es mucho más eficiente que hacer 365 queries individuales
      final allRecordsUnique = await _lactationDatabase.getAllRecords();

      // Contar registros completos (con todos los campos)
      final completeRecords = allRecordsUnique.where((record) {
        return record.vecesPecho > 0 || record.vecesBiberon > 0;
      }).length;

      // Contar registros nocturnos (entre 12am y 6am)
      final now = DateTime.now();
      final nocturnalRecords = allRecordsUnique.where((record) {
        final hour = record.timestamp.hour;
        return hour >= 0 && hour < 6;
      }).length;

      // Obtener registros de hoy
      final todayRecords = await _lactationService.getRecordsForDate(now);
      final dailyRecordsToday = todayRecords.length;

      // Verificar si hay registro nocturno
      final hasNocturnalRecord = todayRecords.any((record) {
        final hour = record.timestamp.hour;
        return hour >= 0 && hour < 6;
      });

      // Obtener estadísticas de lecciones desde Firestore (datos reales)
      int totalLessonsCompleted = 0;
      int totalLessons = 14; // Total de lecciones en la app

      try {
        // Consultar videos completados desde Firestore
        // Usar el userId pasado como parámetro
        final videosCollection = FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('videos');

        // Intentar leer de caché primero
        List<QueryDocumentSnapshot> docs = [];
        try {
          final cacheSnapshot = await videosCollection.get(
            const GetOptions(source: Source.cache),
          );
          if (cacheSnapshot.docs.isNotEmpty) {
            docs = cacheSnapshot.docs;
          }
        } catch (e) {
          // Si no hay caché, leer del servidor
        }

        // Si no hay docs en caché, leer del servidor
        if (docs.isEmpty) {
          try {
            final serverSnapshot = await videosCollection.get(
              const GetOptions(source: Source.server),
            );
            docs = serverSnapshot.docs;
          } catch (e) {
            // Error leyendo del servidor, continuar con datos mock como fallback
          }
        }

        // Procesar videos completados
        final completedVideoIds = <int>{};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final estaCompletado = data['estaCompletado'] as bool? ?? false;
          if (estaCompletado) {
            final videoId = data['videoId'] as int? ?? int.tryParse(doc.id);
            if (videoId != null) {
              completedVideoIds.add(videoId);
            }
          }
        }

        // #region agent log
        final appLogger = getIt<AppLogger>();
        appLogger.d(
          '🔍 [UserStatisticsService] Videos completados encontrados: ${completedVideoIds.length} (IDs: ${completedVideoIds.toList()})',
        );
        // #endregion

        // Calcular lecciones únicas completadas
        if (completedVideoIds.isNotEmpty) {
          try {
            // Obtener todos los videos para mapear videoId -> leccionId
            final allVideos = await VideoService.getVideos();
            final videoToLessonMap = <int, int>{};
            for (final video in allVideos) {
              videoToLessonMap[video.videoId] = video.leccionId;
            }

            // Obtener lecciones únicas de los videos completados
            final uniqueLessons = <int>{};
            for (final videoId in completedVideoIds) {
              final leccionId = videoToLessonMap[videoId];
              if (leccionId != null && leccionId > 0) {
                uniqueLessons.add(leccionId);
              }
            }

            totalLessonsCompleted = uniqueLessons.length;

            // #region agent log
            appLogger.d(
              '🔍 [UserStatisticsService] Lecciones únicas completadas: $totalLessonsCompleted (de ${completedVideoIds.length} videos)',
            );
            // #endregion
          } catch (e) {
            // Si hay error obteniendo videos, usar conteo de videos como aproximación
            totalLessonsCompleted = completedVideoIds.length;
            // #region agent log
            appLogger.w(
              '⚠️ [UserStatisticsService] Error obteniendo videos, usando aproximación: $totalLessonsCompleted',
            );
            // #endregion
          }
        } else {
          // #region agent log
          final appLogger = getIt<AppLogger>();
          appLogger.d(
            '🔍 [UserStatisticsService] No se encontraron videos completados para userId: $userId',
          );
          // #endregion
        }
      } catch (e) {
        // En caso de error, usar datos del repositorio como fallback
        final lessonsResult = await _lessonRepository.getAllLessons();
        lessonsResult.fold((failure) => null, (lessons) {
          totalLessons = lessons.length;
          totalLessonsCompleted = lessons
              .where((lesson) => lesson.isCompleted)
              .length;
        });
      }

      // Obtener registros de peso
      final weightRecords = await _weightDataSource.getAllRecords();
      final babyWeightRecords = weightRecords.length;

      // Obtener registros de sueño
      final sleepRecords = await _sleepDataSource.getAllRecords();
      final babySleepRecords = sleepRecords.length;

      // Obtener estadísticas de trivias desde transacciones XP
      final transactionsResult = await _gamificationRepository
          .getXPTransactions(userId);
      int perfectTrivias = 0;
      int completedTrivias = 0;

      transactionsResult.fold((error) => null, (transactions) {
        // Contar trivias completadas
        final triviaTransactions = transactions.where(
          (t) => t.source == XPSource.triviaCompleted,
        );
        completedTrivias = triviaTransactions.length;

        // Contar trivias perfectas basándose en el bonusReason
        // Las trivias perfectas tienen bonusReason == 'trivia_perfect'
        perfectTrivias = triviaTransactions
            .where((t) => t.bonusReason == 'trivia_perfect')
            .length;
      });

      // Calcular días usando la app (desde la fecha de creación del perfil)
      final profileResult = await _gamificationRepository.getProfile(userId);
      int daysUsingApp = 0;
      profileResult.fold((error) => null, (profile) {
        if (profile != null) {
          daysUsingApp = DateTime.now().difference(profile.createdAt).inDays;
        }
      });

      return UserStatistics(
        totalLactationRecords: allRecordsUnique.length,
        completeLactationRecords: completeRecords,
        totalLessonsCompleted: totalLessonsCompleted,
        totalLessons: totalLessons,
        babyWeightRecords: babyWeightRecords,
        babySleepRecords: babySleepRecords,
        hasNocturnalRecord: hasNocturnalRecord,
        nocturnalRecordsCount: nocturnalRecords,
        dailyRecordsToday: dailyRecordsToday,
        completedTrivias: completedTrivias,
        perfectTrivias: perfectTrivias,
        daysUsingApp: daysUsingApp,
      );
    } catch (e) {
      // En caso de error, retornar estadísticas por defecto
      return UserStatistics(
        totalLactationRecords: 0,
        completeLactationRecords: 0,
        totalLessonsCompleted: 0,
        totalLessons: 0,
        babyWeightRecords: 0,
        babySleepRecords: 0,
        hasNocturnalRecord: false,
        nocturnalRecordsCount: 0,
        dailyRecordsToday: 0,
        completedTrivias: 0,
        perfectTrivias: 0,
        daysUsingApp: 0,
      );
    }
  }
}

/// Estadísticas del usuario para detección de logros
class UserStatistics {
  final int totalLactationRecords;
  final int completeLactationRecords;
  final int totalLessonsCompleted;
  final int totalLessons;
  final int babyWeightRecords;
  final int babySleepRecords;
  final bool hasNocturnalRecord;
  final int nocturnalRecordsCount;
  final int dailyRecordsToday;
  final int completedTrivias;
  final int perfectTrivias;
  final int daysUsingApp;

  UserStatistics({
    required this.totalLactationRecords,
    required this.completeLactationRecords,
    required this.totalLessonsCompleted,
    required this.totalLessons,
    required this.babyWeightRecords,
    required this.babySleepRecords,
    required this.hasNocturnalRecord,
    required this.nocturnalRecordsCount,
    required this.dailyRecordsToday,
    required this.completedTrivias,
    required this.perfectTrivias,
    required this.daysUsingApp,
  });
}
