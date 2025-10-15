import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/lactation_record.dart';

/// Servicio unificado para manejar todos los registros de lactancia en Firestore
class LactationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LactationService(this._firestore, this._auth);

  /// Obtiene la referencia a la subcolección de lactancia del usuario
  CollectionReference get _lactationCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('situacion')
        .doc('seleccion')
        .collection('lactancia');
  }

  /// Guarda un nuevo registro de lactancia
  Future<String> saveRecord(LactationRecord record) async {
    try {
      final docRef = await _lactationCollection.add(record.toMap());
      print('✅ Registro de lactancia guardado: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error guardando registro de lactancia: $e');
      rethrow;
    }
  }

  /// Actualiza un registro existente
  Future<void> updateRecord(String recordId, LactationRecord record) async {
    try {
      await _lactationCollection.doc(recordId).update(record.toMap());
      print('✅ Registro de lactancia actualizado: $recordId');
    } catch (e) {
      print('❌ Error actualizando registro de lactancia: $e');
      rethrow;
    }
  }

  /// Elimina un registro
  Future<void> deleteRecord(String recordId) async {
    try {
      await _lactationCollection.doc(recordId).delete();
      print('✅ Registro de lactancia eliminado: $recordId');
    } catch (e) {
      print('❌ Error eliminando registro de lactancia: $e');
      rethrow;
    }
  }

  /// Obtiene todos los registros de una fecha específica
  Future<List<LactationRecord>> getRecordsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _lactationCollection
          .where(
            'fecha_registro',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where('fecha_registro', isLessThan: endOfDay.toIso8601String())
          .orderBy('fecha_registro', descending: false)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => LactationRecord.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo registros para fecha: $e');
      return [];
    }
  }

  /// Obtiene todos los registros de una semana
  Future<List<LactationRecord>> getRecordsForWeek(DateTime startOfWeek) async {
    try {
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final querySnapshot = await _lactationCollection
          .where(
            'fecha_registro',
            isGreaterThanOrEqualTo: startOfWeek.toIso8601String(),
          )
          .where('fecha_registro', isLessThan: endOfWeek.toIso8601String())
          .orderBy('fecha_registro', descending: false)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => LactationRecord.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo registros para semana: $e');
      return [];
    }
  }

  /// Obtiene todos los registros de un mes
  Future<List<LactationRecord>> getRecordsForMonth(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);

      final querySnapshot = await _lactationCollection
          .where(
            'fecha_registro',
            isGreaterThanOrEqualTo: startOfMonth.toIso8601String(),
          )
          .where('fecha_registro', isLessThan: endOfMonth.toIso8601String())
          .orderBy('fecha_registro', descending: false)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => LactationRecord.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo registros para mes: $e');
      return [];
    }
  }

  /// Obtiene estadísticas de lactancia
  Future<LactationStats> getStats() async {
    try {
      final querySnapshot = await _lactationCollection.get();
      final records = querySnapshot.docs
          .map(
            (doc) => LactationRecord.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      // Calcular estadísticas
      final totalFeeds = records.length;
      final totalDuration = records.fold<Duration>(
        Duration.zero,
        (sum, record) => sum + record.duracion,
      );
      final averageDuration = totalFeeds > 0
          ? Duration(minutes: totalDuration.inMinutes ~/ totalFeeds)
          : Duration.zero;

      // Estadísticas del día actual
      final today = DateTime.now();
      final todayRecords = await getRecordsForDate(today);
      final feedsToday = todayRecords.length;
      final durationToday = todayRecords.fold<Duration>(
        Duration.zero,
        (sum, record) => sum + record.duracion,
      );

      return LactationStats(
        totalFeeds: totalFeeds,
        totalDuration: totalDuration,
        averageDuration: averageDuration,
        feedsToday: feedsToday,
        durationToday: durationToday,
      );
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return LactationStats(
        totalFeeds: 0,
        totalDuration: Duration.zero,
        averageDuration: Duration.zero,
        feedsToday: 0,
        durationToday: Duration.zero,
      );
    }
  }

  /// Verifica si el usuario tiene situación Post-Parto configurada
  Future<bool> hasPostpartumSituation() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Si el usuario tiene email, buscar por email primero
      if (user.email != null) {
        print('🔍 LactationService: Buscando usuario por email: ${user.email}');

        // Buscar el documento del usuario por email
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          print('🔍 LactationService: Usuario encontrado con ID: $userDocId');

          // Ahora buscar la información de situación usando el ID real del usuario
          final docSnapshot = await _firestore
              .collection('Users')
              .doc(userDocId)
              .collection('situacion')
              .doc('seleccion')
              .get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data();
            final situationType = data?['situationType'] as String?;
            print(
              '🔍 LactationService: situationType encontrado: $situationType',
            );
            return situationType == 'postparto';
          } else {
            print('⚠️ LactationService: Documento de situación no existe');
          }
        } else {
          print('❌ LactationService: Usuario no encontrado por email');
        }
      }

      // Fallback: intentar con UID directamente
      print('🔍 LactationService: Intentando con UID: ${user.uid}');
      final docSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('situacion')
          .doc('seleccion')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final situationType = data?['situationType'] as String?;
        return situationType == 'postparto';
      }

      return false;
    } catch (e) {
      print('❌ Error verificando situación Post-Parto: $e');
      return false;
    }
  }

  /// Obtiene un registro específico por ID
  Future<LactationRecord?> getRecordById(String recordId) async {
    try {
      final docSnapshot = await _lactationCollection.doc(recordId).get();
      if (docSnapshot.exists) {
        return LactationRecord.fromMap(
          docSnapshot.data() as Map<String, dynamic>,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo registro por ID: $e');
      return null;
    }
  }
}
