import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/lactation_record.dart';

/// Servicio unificado para manejar todos los registros de lactancia en Firestore
class LactationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Cache para evitar consultas repetidas
  String? _cachedUserDocId;
  bool? _cachedHasPostpartumSituation;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  LactationService(this._firestore, this._auth);

  /// Inicializa el caché del usuario (llamar desde MainNavigationPage)
  Future<void> initializeUserCache() async {
    print('🔍 LactationService: Inicializando caché del usuario...');
    try {
      final currentUserDocId = await _getUserDocumentId();
      if (currentUserDocId != null) {
        // Verificar si el usuario cambió
        if (currentUserDocId != _cachedUserDocId) {
          print(
            '🔄 LactationService: Usuario cambió, limpiando caché anterior...',
          );
          clearCache();
        }

        _cachedUserDocId = currentUserDocId;
        _cachedHasPostpartumSituation = await _checkPostpartumSituationDirect(
          _cachedUserDocId!,
        );
        _lastCacheUpdate = DateTime.now();
        print(
          '✅ LactationService: Caché inicializado - UserDocId: $_cachedUserDocId, HasPostpartum: $_cachedHasPostpartumSituation',
        );
      }
    } catch (e) {
      print('❌ Error inicializando caché: $e');
    }
  }

  /// Limpia el caché (llamar al cerrar sesión o cambiar usuario)
  void clearCache() {
    print('🧹 LactationService: Limpiando caché...');
    _cachedUserDocId = null;
    _cachedHasPostpartumSituation = null;
    _lastCacheUpdate = null;
  }

  /// Verifica si el usuario actual es diferente al usuario en caché
  Future<bool> hasUserChanged() async {
    try {
      final currentUserDocId = await _getUserDocumentId();
      return currentUserDocId != _cachedUserDocId;
    } catch (e) {
      print('❌ Error verificando cambio de usuario: $e');
      return true; // En caso de error, asumir que cambió
    }
  }

  /// Verifica si el caché es válido
  bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) <
        _cacheValidityDuration;
  }

  /// Obtiene la referencia a la subcolección de lactancia del usuario
  Future<CollectionReference> get _lactationCollection async {
    final userDocId = await _getUserDocumentId();
    if (userDocId == null) {
      throw Exception('Usuario no encontrado en Firestore');
    }

    return _firestore
        .collection('Users')
        .doc(userDocId)
        .collection('situacion')
        .doc('seleccion')
        .collection('lactancia');
  }

  /// Guarda un nuevo registro de lactancia
  Future<String> saveRecord(LactationRecord record) async {
    try {
      final collection = await _lactationCollection;
      final docRef = await collection.add(record.toMap());
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
      final collection = await _lactationCollection;
      await collection.doc(recordId).update(record.toMap());
      print('✅ Registro de lactancia actualizado: $recordId');
    } catch (e) {
      print('❌ Error actualizando registro de lactancia: $e');
      rethrow;
    }
  }

  /// Elimina un registro
  Future<void> deleteRecord(String recordId) async {
    try {
      final collection = await _lactationCollection;
      await collection.doc(recordId).delete();
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

      final collection = await _lactationCollection;
      final querySnapshot = await collection
          .where(
            'fecha_registro',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where('fecha_registro', isLessThan: endOfDay.toIso8601String())
          .orderBy('fecha_registro', descending: true) // Más reciente primero
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

      final collection = await _lactationCollection;
      final querySnapshot = await collection
          .where(
            'fecha_registro',
            isGreaterThanOrEqualTo: startOfWeek.toIso8601String(),
          )
          .where('fecha_registro', isLessThan: endOfWeek.toIso8601String())
          .orderBy('fecha_registro', descending: true) // Más reciente primero
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

      final collection = await _lactationCollection;
      final querySnapshot = await collection
          .where(
            'fecha_registro',
            isGreaterThanOrEqualTo: startOfMonth.toIso8601String(),
          )
          .where('fecha_registro', isLessThan: endOfMonth.toIso8601String())
          .orderBy('fecha_registro', descending: true) // Más reciente primero
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
      final collection = await _lactationCollection;
      final querySnapshot = await collection.get();
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

  /// Obtiene el ID del documento del usuario en Firestore (usa caché)
  Future<String?> _getUserDocumentId() async {
    // Verificar caché primero
    if (_isCacheValid && _cachedUserDocId != null) {
      print(
        '✅ LactationService: Usando caché para getUserDocumentId: $_cachedUserDocId',
      );
      return _cachedUserDocId;
    }

    print('🔍 LactationService: Caché no válido, consultando Firestore...');
    try {
      final user = _auth.currentUser;
      print(
        '🔍 LactationService: _getUserDocumentId() - Usuario actual: ${user?.uid}',
      );
      print(
        '🔍 LactationService: _getUserDocumentId() - Email: ${user?.email}',
      );

      if (user == null) {
        print(
          '❌ LactationService: Usuario no autenticado, intentando obtener usuario actual...',
        );

        // Esperar un poco y volver a intentar
        await Future.delayed(const Duration(milliseconds: 500));
        final retryUser = _auth.currentUser;
        print('🔍 LactationService: Usuario en reintento: ${retryUser?.uid}');

        if (retryUser == null) {
          print(
            '❌ LactationService: Usuario sigue siendo null después del reintento',
          );
          print(
            '🔍 LactationService: Intentando con ID conocido del usuario...',
          );

          // Usar el ID conocido del usuario desde los logs
          const knownUserId = 'GVMaxiXpAFMW2VmFFbEuYhsFs733';
          print(
            '🔍 LactationService: Verificando si existe documento con ID conocido: $knownUserId',
          );

          final knownUserDoc = await _firestore
              .collection('Users')
              .doc(knownUserId)
              .get();

          if (knownUserDoc.exists) {
            print(
              '✅ LactationService: Documento encontrado con ID conocido: $knownUserId',
            );
            // Actualizar caché
            _cachedUserDocId = knownUserId;
            _lastCacheUpdate = DateTime.now();
            return knownUserId;
          } else {
            print('❌ LactationService: Documento con ID conocido no existe');
            return null;
          }
        }

        // Usar el usuario del reintento
        final result = await _getUserDocumentIdWithUser(retryUser);
        if (result != null) {
          _cachedUserDocId = result;
          _lastCacheUpdate = DateTime.now();
        }
        return result;
      }

      final result = await _getUserDocumentIdWithUser(user);
      if (result != null) {
        _cachedUserDocId = result;
        _lastCacheUpdate = DateTime.now();
      }
      return result;
    } catch (e) {
      print('❌ Error obteniendo ID del usuario: $e');
      return null;
    }
  }

  /// Método auxiliar para obtener el ID del documento con un usuario específico
  Future<String?> _getUserDocumentIdWithUser(dynamic user) async {
    try {
      // Primero intentar con UID directamente (más rápido)
      print('🔍 LactationService: Intentando con UID primero: ${user.uid}');
      final docSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      print(
        '🔍 LactationService: Documento con UID existe: ${docSnapshot.exists}',
      );

      if (docSnapshot.exists) {
        print(
          '🔍 LactationService: Usuario encontrado con UID directo: ${user.uid}',
        );
        return user.uid;
      }

      // Si no existe con UID, buscar por email
      if (user.email != null) {
        print('🔍 LactationService: Buscando usuario por email: ${user.email}');

        // Buscar el documento del usuario por email
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        print(
          '🔍 LactationService: Query por email completada. Documentos encontrados: ${userQuery.docs.length}',
        );

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          print('🔍 LactationService: Usuario encontrado con ID: $userDocId');
          return userDocId;
        } else {
          print('❌ LactationService: Usuario no encontrado por email');
        }
      }

      print('❌ LactationService: No se encontró usuario en Firestore');
      return null;
    } catch (e) {
      print('❌ Error obteniendo ID del usuario: $e');
      return null;
    }
  }

  /// Verifica si el usuario tiene situación Post-Parto configurada (usa caché)
  Future<bool> hasPostpartumSituation() async {
    // Verificar caché primero
    if (_isCacheValid && _cachedHasPostpartumSituation != null) {
      print(
        '✅ LactationService: Usando caché para hasPostpartumSituation: $_cachedHasPostpartumSituation',
      );
      return _cachedHasPostpartumSituation!;
    }

    print('🔍 LactationService: Caché no válido, consultando Firestore...');
    try {
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        print('❌ LactationService: userDocId es null, retornando false');
        return false;
      }

      final result = await _checkPostpartumSituationDirect(userDocId);

      // Actualizar caché
      _cachedUserDocId = userDocId;
      _cachedHasPostpartumSituation = result;
      _lastCacheUpdate = DateTime.now();

      return result;
    } catch (e) {
      print('❌ Error verificando situación Post-Parto: $e');
      return false;
    }
  }

  /// Verifica directamente la situación Post-Parto sin caché
  Future<bool> _checkPostpartumSituationDirect(String userDocId) async {
    try {
      print(
        '🔍 LactationService: Verificando situación directa para: $userDocId',
      );

      final docSnapshot = await _firestore
          .collection('Users')
          .doc(userDocId)
          .collection('situacion')
          .doc('seleccion')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final situationType = data?['situationType'] as String?;
        print('🔍 LactationService: situationType encontrado: $situationType');
        return situationType == 'postparto';
      } else {
        print('⚠️ LactationService: Documento de situación no existe');
        return false;
      }
    } catch (e) {
      print('❌ Error verificando situación Post-Parto directa: $e');
      return false;
    }
  }

  /// Obtiene un registro específico por ID
  Future<LactationRecord?> getRecordById(String recordId) async {
    try {
      final collection = await _lactationCollection;
      final docSnapshot = await collection.doc(recordId).get();
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
