import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/settings_entities.dart';
import '../datasources/settings_remote_data_source.dart';
import '../models/settings_models.dart';

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final FirebaseFirestore firestore;

  SettingsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<AppConfigurationModel> getAppConfiguration(String userId) async {
    try {
      final doc = await firestore
          .collection('app_configurations')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) {
        throw NotFoundException(
          message: 'Configuración no encontrada para el usuario',
        );
      }

      return AppConfigurationModel.fromQueryDocument(doc.docs.first);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        message: 'Error al obtener configuración: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveAppConfiguration(AppConfigurationModel configuration) async {
    try {
      await firestore
          .collection('app_configurations')
          .doc(configuration.id)
          .set(configuration.toDocument());
    } catch (e) {
      throw ServerException(
        message: 'Error al guardar configuración: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateAppConfiguration(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final query = await firestore
          .collection('app_configurations')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw NotFoundException(
          message: 'Configuración no encontrada para el usuario',
        );
      }

      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await firestore
          .collection('app_configurations')
          .doc(query.docs.first.id)
          .update(updates);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        message: 'Error al actualizar configuración: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteAppConfiguration(String userId) async {
    try {
      final query = await firestore
          .collection('app_configurations')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw NotFoundException(
          message: 'Configuración no encontrada para el usuario',
        );
      }

      await firestore
          .collection('app_configurations')
          .doc(query.docs.first.id)
          .delete();
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        message: 'Error al eliminar configuración: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserStatisticsModel> getUserStatistics(String userId) async {
    try {
      final doc = await firestore
          .collection('user_statistics')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) {
        throw NotFoundException(
          message: 'Estadísticas no encontradas para el usuario',
        );
      }

      return UserStatisticsModel.fromDocument(doc.docs.first);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        message: 'Error al obtener estadísticas: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveUserStatistics(UserStatisticsModel statistics) async {
    try {
      await firestore
          .collection('user_statistics')
          .doc(statistics.id)
          .set(statistics.toDocument());
    } catch (e) {
      throw ServerException(
        message: 'Error al guardar estadísticas: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateUserStatistics(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final query = await firestore
          .collection('user_statistics')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw NotFoundException(
          message: 'Estadísticas no encontradas para el usuario',
        );
      }

      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await firestore
          .collection('user_statistics')
          .doc(query.docs.first.id)
          .update(updates);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        message: 'Error al actualizar estadísticas: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> incrementUserStatistics(
    String userId,
    Map<String, dynamic> increments,
  ) async {
    try {
      final query = await firestore
          .collection('user_statistics')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw NotFoundException(
          message: 'Estadísticas no encontradas para el usuario',
        );
      }

      final docRef = firestore
          .collection('user_statistics')
          .doc(query.docs.first.id);

      // Usar FieldValue.increment para incrementar valores numéricos
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      for (final entry in increments.entries) {
        if (entry.value is int) {
          updates[entry.key] = FieldValue.increment(entry.value as int);
        } else {
          updates[entry.key] = entry.value;
        }
      }

      await docRef.update(updates);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        message: 'Error al incrementar estadísticas: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteUserStatistics(String userId) async {
    try {
      final query = await firestore
          .collection('user_statistics')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw NotFoundException(
          message: 'Estadísticas no encontradas para el usuario',
        );
      }

      await firestore
          .collection('user_statistics')
          .doc(query.docs.first.id)
          .delete();
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        message: 'Error al eliminar estadísticas: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<FeedbackMessageModel>> getUserFeedbackMessages(
    String userId,
  ) async {
    try {
      final query = await firestore
          .collection('feedback_messages')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => FeedbackMessageModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener mensajes de feedback: ${e.toString()}',
      );
    }
  }

  @override
  Future<FeedbackMessageModel> getFeedbackMessageById(String messageId) async {
    try {
      final doc = await firestore
          .collection('feedback_messages')
          .doc(messageId)
          .get();

      if (!doc.exists) {
        throw NotFoundException(message: 'Mensaje de feedback no encontrado');
      }

      return FeedbackMessageModel.fromDocument(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        message: 'Error al obtener mensaje de feedback: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveFeedbackMessage(FeedbackMessageModel message) async {
    try {
      await firestore
          .collection('feedback_messages')
          .doc(message.id)
          .set(message.toDocument());
    } catch (e) {
      throw ServerException(
        message: 'Error al guardar mensaje de feedback: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateFeedbackMessage(
    String messageId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await firestore
          .collection('feedback_messages')
          .doc(messageId)
          .update(updates);
    } catch (e) {
      throw ServerException(
        message: 'Error al actualizar mensaje de feedback: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteFeedbackMessage(String messageId) async {
    try {
      await firestore.collection('feedback_messages').doc(messageId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Error al eliminar mensaje de feedback: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> checkIfConfigurationExists(String userId) async {
    try {
      final query = await firestore
          .collection('app_configurations')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw ServerException(
        message: 'Error al verificar configuración: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> checkIfStatisticsExist(String userId) async {
    try {
      final query = await firestore
          .collection('user_statistics')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw ServerException(
        message: 'Error al verificar estadísticas: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> getFeedbackMessageCount(String userId) async {
    try {
      final query = await firestore
          .collection('feedback_messages')
          .where('userId', isEqualTo: userId)
          .get();

      return query.docs.length;
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener conteo de mensajes: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ChartData>> getVideoViewsChartData(String userId) async {
    try {
      // TODO: Implementar lógica real de obtención de datos de gráfico
      // Por ahora retornamos datos de ejemplo
      return [
        const ChartData(label: 'Enero', value: 10.0),
        const ChartData(label: 'Febrero', value: 15.0),
        const ChartData(label: 'Marzo', value: 20.0),
        const ChartData(label: 'Abril', value: 25.0),
      ];
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener datos de gráfico de videos: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ChartData>> getContentCompletionChartData(String userId) async {
    try {
      // TODO: Implementar lógica real de obtención de datos de gráfico
      // Por ahora retornamos datos de ejemplo
      return [
        const ChartData(label: 'Lecciones', value: 80.0),
        const ChartData(label: 'Videos', value: 60.0),
        const ChartData(label: 'Tips', value: 90.0),
        const ChartData(label: 'Ejercicios', value: 70.0),
      ];
    } catch (e) {
      throw ServerException(
        message:
            'Error al obtener datos de gráfico de completación: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getOverallProgress(String userId) async {
    try {
      // TODO: Implementar lógica real de obtención de progreso general
      // Por ahora retornamos datos de ejemplo
      return {
        'totalProgress': 75.0,
        'lessonsCompleted': 15,
        'videosWatched': 25,
        'tipsRead': 30,
        'exercisesCompleted': 10,
        'lastActivity': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener progreso general: ${e.toString()}',
      );
    }
  }
}
