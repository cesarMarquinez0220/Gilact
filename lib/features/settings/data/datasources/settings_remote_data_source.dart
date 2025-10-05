import '../models/settings_models.dart';
import '../../domain/entities/settings_entities.dart';

abstract class SettingsRemoteDataSource {
  // Configuración de la aplicación
  Future<AppConfigurationModel> getAppConfiguration(String userId);
  Future<void> saveAppConfiguration(AppConfigurationModel configuration);
  Future<void> updateAppConfiguration(
    String userId,
    Map<String, dynamic> updates,
  );
  Future<void> deleteAppConfiguration(String userId);

  // Estadísticas del usuario
  Future<UserStatisticsModel> getUserStatistics(String userId);
  Future<void> saveUserStatistics(UserStatisticsModel statistics);
  Future<void> updateUserStatistics(
    String userId,
    Map<String, dynamic> updates,
  );
  Future<void> incrementUserStatistics(
    String userId,
    Map<String, dynamic> increments,
  );
  Future<void> deleteUserStatistics(String userId);

  // Mensajes de feedback
  Future<List<FeedbackMessageModel>> getUserFeedbackMessages(String userId);
  Future<FeedbackMessageModel> getFeedbackMessageById(String messageId);
  Future<void> saveFeedbackMessage(FeedbackMessageModel message);
  Future<void> updateFeedbackMessage(
    String messageId,
    Map<String, dynamic> updates,
  );
  Future<void> deleteFeedbackMessage(String messageId);

  // Métodos de utilidad
  Future<bool> checkIfConfigurationExists(String userId);
  Future<bool> checkIfStatisticsExist(String userId);
  Future<int> getFeedbackMessageCount(String userId);

  // Métodos de gráficos y progreso
  Future<List<ChartData>> getVideoViewsChartData(String userId);
  Future<List<ChartData>> getContentCompletionChartData(String userId);
  Future<Map<String, dynamic>> getOverallProgress(String userId);
}
