import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/settings_entities.dart';

abstract class SettingsRepository {
  // Métodos de configuración
  Future<Either<Failure, AppConfiguration>> getAppConfiguration(String userId);
  
  Future<Either<Failure, void>> updateAppConfiguration(AppConfiguration configuration);
  
  Future<Either<Failure, void>> resetAppConfiguration(String userId);
  
  // Métodos de estadísticas
  Future<Either<Failure, UserStatistics>> getUserStatistics(String userId);
  
  Future<Either<Failure, void>> updateUserStatistics(UserStatistics statistics);
  
  Future<Either<Failure, List<ChartData>>> getVideoViewsChartData(String userId);
  
  Future<Either<Failure, List<ChartData>>> getContentCompletionChartData(String userId);
  
  Future<Either<Failure, Map<String, dynamic>>> getOverallProgress(String userId);
  
  // Métodos de feedback
  Future<Either<Failure, void>> submitFeedback(FeedbackMessage feedback);
  
  Future<Either<Failure, List<FeedbackMessage>>> getUserFeedback(String userId);
  
  Future<Either<Failure, void>> updateFeedbackStatus(String feedbackId, String status);
}
