import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/app_logger.dart';
import '../../domain/services/lactation_decision_tree.dart';
import '../../domain/entities/lactation_record.dart';
import 'sleep_reminder_service.dart';

/// Servicio para manejar el flujo de registro de lactancia
class LactationFlowService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AppLogger _logger;

  LactationFlowService(this._firestore, this._auth, this._logger);

  /// Guarda un registro de lactancia basado en el contexto del flujo
  Future<void> saveLactationRecord({
    required LactationFlowContext context,
    DateTime? selectedDate,
    String? existingRecordId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar situación Post-Parto
      final userDocId = await _getUserDocumentId(user);
      if (userDocId == null) {
        throw Exception('Usuario no encontrado');
      }

      final situacionDocRef = _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion');

      final situacionSnapshot = await situacionDocRef.get();
      if (!situacionSnapshot.exists) {
        throw Exception('Debes completar el proceso de onboarding');
      }

      final data = situacionSnapshot.data();
      final situationType = data?['situationType'] as String?;
      if (situationType != 'postparto') {
        throw Exception(
          'Solo usuarios en situación Post-Parto pueden registrar lactancia',
        );
      }

      // Preparar datos de lactancia
      final fechaRegistro = selectedDate ?? DateTime.now();
      final timestampRegistro = DateTime.now();

      Map<String, dynamic> datosLactancia = {
        'volumen_extraccion':
            int.tryParse(context.data['extractionVolume'] ?? '0') ?? 0,
        'unidad_volumen': 'ml',
        'veces_biberon': context.data['bottleVolume'] != '0' ? 1 : 0,
        'veces_pecho': context.hasBreastfeeding ? 1 : 0,
        'pecho_dado': context.data['breastSide'] ?? 'Ninguna',
        'horas_sueno_bebe': int.tryParse(context.data['sleepTime'] ?? '0') ?? 0,
        'unidad_sueno': 'Min',
        'timestamp': Timestamp.fromDate(timestampRegistro),
        'fecha_registro': fechaRegistro.toIso8601String(),
        'hora_registro': timestampRegistro.toIso8601String(),
        'duracion': int.tryParse(context.data['breastDuration'] ?? '0') ?? 0,
        'tipo': context.hasBreastfeeding ? 'breast' : 'bottle',
        'flujo_completado': true,
        'historial_flujo': context.history,
      };

      // Guardar o actualizar
      if (existingRecordId != null) {
        await situacionDocRef
            .collection('lactancia')
            .doc(existingRecordId)
            .update(datosLactancia);
      } else {
        await situacionDocRef.collection('lactancia').add(datosLactancia);
      }

      // Programar recordatorio de sueño para las 8 AM del día siguiente
      await _scheduleSleepReminder(context);
    } catch (e) {
      throw Exception('Error al guardar registro: ${e.toString()}');
    }
  }

  /// Programa un recordatorio de sueño para las 8 AM del día siguiente
  Future<void> _scheduleSleepReminder(LactationFlowContext context) async {
    try {
      // Obtener el tipo de alimentación
      final initialChoice =
          context.data['initial']?.toString().toLowerCase() ?? 'pecho';
      String feedingType;

      switch (initialChoice) {
        case 'pecho':
          feedingType = 'pecho';
          break;
        case 'biberon':
          feedingType = 'biberon';
          break;
        case 'mixto':
          feedingType = 'mixto';
          break;
        default:
          feedingType = 'pecho';
      }

      // Programar el recordatorio
      await SleepReminderService.scheduleSleepReminder(
        feedingTime: DateTime.now(),
        feedingType: feedingType,
      );

      _logger.success(
        'Recordatorio de sueño programado para mañana a las 8 AM',
      );
    } catch (e, stackTrace) {
      _logger.w('Error programando recordatorio de sueño', e, stackTrace);
      // No lanzar excepción para no interrumpir el guardado del registro
    }
  }

  /// Elimina un registro de lactancia
  Future<void> deleteLactationRecord(String recordId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final userDocId = await _getUserDocumentId(user);
      if (userDocId == null) {
        throw Exception('Usuario no encontrado');
      }

      await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .collection('lactancia')
          .doc(recordId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar registro: ${e.toString()}');
    }
  }

  /// Obtiene un registro existente para edición
  Future<LactationRecord?> getExistingRecord(String recordId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDocId = await _getUserDocumentId(user);
      if (userDocId == null) return null;

      final docSnapshot = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .collection('lactancia')
          .doc(recordId)
          .get();

      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data()!;
      return LactationRecord.fromMap(data, recordId);
    } catch (e) {
      return null;
    }
  }

  /// Convierte un registro existente a contexto de flujo
  LactationFlowContext recordToFlowContext(LactationRecord record) {
    final data = <String, dynamic>{};

    // Determinar tipo de alimentación
    if (record.vecesPecho > 0 && record.vecesBiberon > 0) {
      data['initial'] = 'ambos';
    } else if (record.vecesPecho > 0) {
      data['initial'] = 'pecho';
    } else {
      data['initial'] = 'biberon';
    }

    // Datos específicos
    data['breastSide'] = record.pechoDado;
    data['breastDuration'] = record.duracion.inMinutes.toString();
    data['bottleVolume'] = record.vecesBiberon > 0 ? '60' : '0';
    data['sleepTime'] = record.horasSuenoBebe.toString();
    data['extractionVolume'] = record.volumenExtraccion.toString();

    return LactationFlowContext(
      data: data,
      currentStep: LactationStep.confirmation,
      history: ['Cargado desde registro existente'],
    );
  }

  /// Obtiene estadísticas del usuario para sugerencias inteligentes
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final userDocId = await _getUserDocumentId(user);
      if (userDocId == null) return {};

      final querySnapshot = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .collection('lactancia')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      if (querySnapshot.docs.isEmpty) return {};

      // Calcular estadísticas
      int totalBreastfeeding = 0;
      int totalBottle = 0;
      int totalSleepTime = 0;
      int totalExtraction = 0;
      List<int> durations = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();

        if (data['veces_pecho'] > 0) totalBreastfeeding++;
        if (data['veces_biberon'] > 0) totalBottle++;
        totalSleepTime += (data['horas_sueno_bebe'] ?? 0) as int;
        totalExtraction += (data['volumen_extraccion'] ?? 0) as int;

        if (data['duracion'] != null) {
          durations.add(data['duracion'] as int);
        }
      }

      final avgDuration = durations.isNotEmpty
          ? durations.reduce((a, b) => a + b) / durations.length
          : 0;

      return {
        'totalRecords': querySnapshot.docs.length,
        'totalBreastfeeding': totalBreastfeeding,
        'totalBottle': totalBottle,
        'avgSleepTime': totalSleepTime / querySnapshot.docs.length,
        'avgExtraction': totalExtraction / querySnapshot.docs.length,
        'avgDuration': avgDuration,
        'preferredFeedingType': totalBreastfeeding > totalBottle
            ? 'breast'
            : 'bottle',
      };
    } catch (e) {
      return {};
    }
  }

  /// Obtiene sugerencias inteligentes basadas en el historial del usuario
  Future<List<String>> getIntelligentSuggestions({
    required LactationStep currentStep,
    Map<String, dynamic>? userStats,
  }) async {
    final stats = userStats ?? await getUserStatistics();

    switch (currentStep) {
      case LactationStep.breastDuration:
        if (stats['avgDuration'] > 0) {
          final avg = stats['avgDuration'].round();
          return [
            '${avg - 5} min',
            '$avg min',
            '${avg + 5} min',
            '${avg + 10} min',
          ];
        }
        return ['5 min', '10 min', '15 min', '20 min'];

      case LactationStep.bottleVolume:
        if (stats['avgExtraction'] > 0) {
          final avg = stats['avgExtraction'].round();
          return [
            '${avg - 30} ml',
            '$avg ml',
            '${avg + 30} ml',
            '${avg + 60} ml',
          ];
        }
        return ['60 ml', '90 ml', '120 ml', '150 ml'];

      case LactationStep.sleepTime:
        if (stats['avgSleepTime'] > 0) {
          final avg = stats['avgSleepTime'].round();
          return [
            '${avg - 30} min',
            '$avg min',
            '${avg + 30} min',
            '${avg + 60} min',
          ];
        }
        return ['30 min', '1 hora', '2 horas', '3 horas'];

      case LactationStep.extractionVolume:
        if (stats['avgExtraction'] > 0) {
          final avg = stats['avgExtraction'].round();
          return [
            '${avg - 30} ml',
            '$avg ml',
            '${avg + 30} ml',
            '${avg + 60} ml',
          ];
        }
        return ['30 ml', '60 ml', '90 ml', '120 ml'];

      default:
        return [];
    }
  }

  /// Valida si el usuario puede registrar lactancia
  Future<bool> canUserRegisterLactation() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDocId = await _getUserDocumentId(user);
      if (userDocId == null) return false;

      final situacionSnapshot = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .get();

      if (!situacionSnapshot.exists) return false;

      final data = situacionSnapshot.data();
      return data?['situationType'] == 'postparto';
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el ID del documento del usuario
  Future<String?> _getUserDocumentId(User user) async {
    try {
      // Intentar buscar por email primero
      if (user.email != null) {
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          return userQuery.docs.first.id;
        }
      }

      // Fallback: intentar con UID directamente
      final docSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        return user.uid;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
