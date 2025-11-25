import 'package:injectable/injectable.dart';
import '../../../../core/di/injection.dart';
import '../../../lactation/data/services/lactation_service.dart';
import '../../../lactation/data/datasources/lactation_database.dart';
import '../../../lessons/domain/repositories/lesson_repository.dart';
import '../../../lactation/data/datasources/baby_weight_offline_local_data_source.dart';
import '../../../lactation/data/datasources/sleep_offline_local_data_source.dart';
import '../repositories/gamification_repository.dart';
import '../entities/xp_transaction.dart';

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

      // Obtener estadísticas de lecciones
      final lessonsResult = await _lessonRepository.getAllLessons();
      int totalLessonsCompleted = 0;
      int totalLessons = 0;

      lessonsResult.fold((failure) => null, (lessons) {
        totalLessons = lessons.length;
        totalLessonsCompleted = lessons
            .where((lesson) => lesson.isCompleted)
            .length;
      });

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

        // Contar trivias perfectas (100% - esto requiere lógica adicional)
        // Por ahora, asumimos que si hay una transacción de trivia, fue completada
        // Para detectar trivias perfectas, necesitaríamos guardar el porcentaje
        perfectTrivias = completedTrivias; // Placeholder - mejorar después
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
