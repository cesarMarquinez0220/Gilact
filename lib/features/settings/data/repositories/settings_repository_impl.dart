import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/settings_models.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AppConfiguration>> getAppConfiguration(
    String userId,
  ) async {
    try {
      final configuration = await remoteDataSource.getAppConfiguration(userId);
      return Right(configuration);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Configuración no encontrada'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> saveAppConfiguration(
    AppConfiguration configuration,
  ) async {
    try {
      final model = AppConfigurationModel(
        id: configuration.id,
        userId: configuration.userId,
        notificationsEnabled: configuration.notificationsEnabled,
        analyticsEnabled: configuration.analyticsEnabled,
        crashReportingEnabled: configuration.crashReportingEnabled,
        language: configuration.language,
        theme: configuration.theme,
        autoSaveProgress: configuration.autoSaveProgress,
        showTips: configuration.showTips,
        darkMode: configuration.darkMode,
        fontSize: configuration.fontSize,
        soundEnabled: configuration.soundEnabled,
        vibrationEnabled: configuration.vibrationEnabled,
        createdAt: configuration.createdAt,
        updatedAt: configuration.updatedAt,
      );

      await remoteDataSource.saveAppConfiguration(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAppConfiguration(
    AppConfiguration configuration,
  ) async {
    try {
      final model = AppConfigurationModel(
        id: configuration.id,
        userId: configuration.userId,
        notificationsEnabled: configuration.notificationsEnabled,
        analyticsEnabled: configuration.analyticsEnabled,
        crashReportingEnabled: configuration.crashReportingEnabled,
        language: configuration.language,
        theme: configuration.theme,
        autoSaveProgress: configuration.autoSaveProgress,
        showTips: configuration.showTips,
        darkMode: configuration.darkMode,
        fontSize: configuration.fontSize,
        soundEnabled: configuration.soundEnabled,
        vibrationEnabled: configuration.vibrationEnabled,
        createdAt: configuration.createdAt,
        updatedAt: configuration.updatedAt,
      );

      await remoteDataSource.updateAppConfiguration(
        configuration.userId,
        model.toDocument(),
      );
      return const Right(null);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Configuración no encontrada'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetAppConfiguration(String userId) async {
    try {
      await remoteDataSource.deleteAppConfiguration(userId);
      return const Right(null);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Configuración no encontrada'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> deleteAppConfiguration(String userId) async {
    try {
      await remoteDataSource.deleteAppConfiguration(userId);
      return const Right(null);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Configuración no encontrada'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserStatistics>> getUserStatistics(
    String userId,
  ) async {
    try {
      final statistics = await remoteDataSource.getUserStatistics(userId);
      return Right(statistics);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Estadísticas no encontradas'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> saveUserStatistics(
    UserStatistics statistics,
  ) async {
    try {
      final model = UserStatisticsModel(
        id: statistics.id,
        userId: statistics.userId,
        totalVideosWatched: statistics.totalVideosWatched,
        totalLessonsCompleted: statistics.totalLessonsCompleted,
        totalContentCompleted: statistics.totalContentCompleted,
        totalTimeSpent: statistics.totalTimeSpent,
        averageSessionTime: statistics.averageSessionTime,
        totalSessions: statistics.totalSessions,
        videosWatchedByCategory: statistics.videosWatchedByCategory,
        contentCompletedByCategory: statistics.contentCompletedByCategory,
        lastActivity: statistics.lastActivity,
        firstActivity: statistics.firstActivity,
        createdAt: statistics.createdAt,
        updatedAt: statistics.updatedAt,
      );

      await remoteDataSource.saveUserStatistics(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserStatistics(
    UserStatistics statistics,
  ) async {
    try {
      final model = UserStatisticsModel(
        id: statistics.id,
        userId: statistics.userId,
        totalVideosWatched: statistics.totalVideosWatched,
        totalLessonsCompleted: statistics.totalLessonsCompleted,
        totalContentCompleted: statistics.totalContentCompleted,
        totalTimeSpent: statistics.totalTimeSpent,
        averageSessionTime: statistics.averageSessionTime,
        totalSessions: statistics.totalSessions,
        videosWatchedByCategory: statistics.videosWatchedByCategory,
        contentCompletedByCategory: statistics.contentCompletedByCategory,
        lastActivity: statistics.lastActivity,
        firstActivity: statistics.firstActivity,
        createdAt: statistics.createdAt,
        updatedAt: statistics.updatedAt,
      );

      await remoteDataSource.updateUserStatistics(
        statistics.userId,
        model.toDocument(),
      );
      return const Right(null);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Estadísticas no encontradas'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> incrementUserStatistics(
    String userId,
    Map<String, dynamic> increments,
  ) async {
    try {
      await remoteDataSource.incrementUserStatistics(userId, increments);
      return const Right(null);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Estadísticas no encontradas'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> deleteUserStatistics(String userId) async {
    try {
      await remoteDataSource.deleteUserStatistics(userId);
      return const Right(null);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Estadísticas no encontradas'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<FeedbackMessage>>> getUserFeedbackMessages(
    String userId,
  ) async {
    try {
      final messages = await remoteDataSource.getUserFeedbackMessages(userId);
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, FeedbackMessage>> getFeedbackMessageById(
    String messageId,
  ) async {
    try {
      final message = await remoteDataSource.getFeedbackMessageById(messageId);
      return Right(message);
    } on NotFoundException {
      return const Left(
        NotFoundFailure(message: 'Mensaje de feedback no encontrado'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> saveFeedbackMessage(
    FeedbackMessage message,
  ) async {
    try {
      final model = FeedbackMessageModel(
        id: message.id,
        userId: message.userId,
        message: message.message,
        type: message.type,
        status: message.status,
        createdAt: message.createdAt,
        reviewedAt: message.reviewedAt,
        response: message.response,
      );

      await remoteDataSource.saveFeedbackMessage(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> updateFeedbackMessage(
    String messageId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await remoteDataSource.updateFeedbackMessage(messageId, updates);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> deleteFeedbackMessage(String messageId) async {
    try {
      await remoteDataSource.deleteFeedbackMessage(messageId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<Either<Failure, bool>> checkIfConfigurationExists(
    String userId,
  ) async {
    try {
      final exists = await remoteDataSource.checkIfConfigurationExists(userId);
      return Right(exists);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ChartData>>> getVideoViewsChartData(
    String userId,
  ) async {
    try {
      final chartData = await remoteDataSource.getVideoViewsChartData(userId);
      return Right(chartData);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ChartData>>> getContentCompletionChartData(
    String userId,
  ) async {
    try {
      final chartData = await remoteDataSource.getContentCompletionChartData(
        userId,
      );
      return Right(chartData);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOverallProgress(
    String userId,
  ) async {
    try {
      final progress = await remoteDataSource.getOverallProgress(userId);
      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> submitFeedback(FeedbackMessage feedback) async {
    try {
      final model = FeedbackMessageModel(
        id: feedback.id,
        userId: feedback.userId,
        message: feedback.message,
        type: feedback.type,
        status: feedback.status,
        createdAt: feedback.createdAt,
        reviewedAt: feedback.reviewedAt,
        response: feedback.response,
      );

      await remoteDataSource.saveFeedbackMessage(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FeedbackMessage>>> getUserFeedback(
    String userId,
  ) async {
    try {
      final feedbackMessages = await remoteDataSource.getUserFeedbackMessages(
        userId,
      );
      return Right(feedbackMessages);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFeedbackStatus(
    String feedbackId,
    String status,
  ) async {
    try {
      await remoteDataSource.updateFeedbackMessage(feedbackId, {
        'status': status,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  // Métodos de configuración local
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLocalSettings() async {
    try {
      final settings = await localDataSource.getAllLocalSettings();
      return Right(settings);
    } catch (e) {
      return Left(UnknownFailure(message: 'Error obteniendo configuraciones locales: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocalSetting(
    String key,
    dynamic value,
  ) async {
    try {
      switch (key) {
        case 'soundEnabled':
          await localDataSource.setSoundEnabled(value as bool);
          break;
        case 'vibrationEnabled':
          await localDataSource.setVibrationEnabled(value as bool);
          break;
        case 'autoSaveProgress':
          await localDataSource.setAutoSaveProgress(value as bool);
          break;
        case 'language':
          await localDataSource.setLanguage(value as String);
          break;
        case 'appVersion':
          await localDataSource.setAppVersion(value as String);
          break;
        default:
          return Left(UnknownFailure(message: 'Clave de configuración desconocida: $key'));
      }
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: 'Error actualizando configuración local: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocalSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      for (final entry in settings.entries) {
        await updateLocalSetting(entry.key, entry.value);
      }
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: 'Error actualizando configuraciones locales: ${e.toString()}'));
    }
  }
}
