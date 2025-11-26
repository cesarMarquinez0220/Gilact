import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/app_logger.dart';

/// Servicio especializado para manejar las subcolecciones del usuario
@singleton
class UserSubcollectionsService {
  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  UserSubcollectionsService(this._firestore, this._logger);

  /// Crea las subcolecciones necesarias para un usuario
  Future<void> createUserSubcollections(String userId) async {
    try {
      _logger.d(
        'UserSubcollectionsService: Creando subcolecciones para usuario: $userId',
      );

      // Solo crear subcolección 'situacion' para información de la situación
      await _createSituacionSubcollection(userId);

      // La subcolección 'videos' se creará dinámicamente cuando el usuario pausa por primera vez
      _logger.success(
        'UserSubcollectionsService: Subcolección situacion creada exitosamente',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'UserSubcollectionsService: Error creando subcolecciones',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Crea la subcolección 'situacion' para información de la situación
  Future<void> _createSituacionSubcollection(String userId) async {
    // La subcolección se creará automáticamente cuando se agreguen documentos
    _logger.d('Subcolección situacion preparada');
  }

  /// Guarda la selección temporal de situación (antes de completar formularios)
  Future<void> saveTemporarySituation(String userId, String situation) async {
    try {
      // Guardar en SharedPreferences como selección temporal
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_situation_$userId', situation);
      _logger.success('Selección temporal guardada: $situation');
    } catch (e, stackTrace) {
      _logger.e('Error guardando selección temporal', e, stackTrace);
      rethrow;
    }
  }

  /// Obtiene la selección temporal de situación
  Future<String?> getTemporarySituation(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('temp_situation_$userId');
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo selección temporal', e, stackTrace);
      return null;
    }
  }

  /// Limpia la selección temporal después de completar el proceso
  Future<void> clearTemporarySituation(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_situation_$userId');
      _logger.success('Selección temporal limpiada');
    } catch (e, stackTrace) {
      _logger.e('Error limpiando selección temporal', e, stackTrace);
    }
  }

  /// Guarda la situación seleccionada por el usuario (después de completar formularios)
  Future<void> saveUserSituation(String userId, String situation) async {
    try {
      final batch = _firestore.batch();

      // Crear documento de situación actual
      final currentSituationRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('situacion')
          .doc('current');

      batch.set(currentSituationRef, {
        'situacion': situation,
        'fechaSeleccion': Timestamp.fromDate(DateTime.now()),
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'active',
      });

      await batch.commit();
      _logger.success('Situación guardada exitosamente: $situation');
    } catch (e, stackTrace) {
      _logger.e('Error guardando situación', e, stackTrace);
      rethrow;
    }
  }

  /// Verifica si el usuario ya tiene la subcolección de situación creada
  Future<bool> hasSubcollections(String userId) async {
    try {
      final situacionDoc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('situacion')
          .doc('seleccion')
          .get();

      return situacionDoc.exists;
    } catch (e, stackTrace) {
      _logger.e('Error verificando subcolecciones', e, stackTrace);
      return false;
    }
  }

  /// Obtiene la situación actual del usuario
  Future<String?> getUserCurrentSituation(String userId) async {
    try {
      final doc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('situacion')
          .doc('seleccion')
          .get();

      if (doc.exists) {
        return doc.data()?['situationType'] as String?;
      }
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo situación actual', e, stackTrace);
      return null;
    }
  }

  /// Obtiene todos los datos de la situación del usuario
  Future<Map<String, dynamic>?> getUserSituationData(String userId) async {
    try {
      // Si userId parece ser un email, buscar por email primero
      if (userId.contains('@')) {
        _logger.d(
          'UserSubcollectionsService: Buscando usuario por email: $userId',
        );

        // Buscar el documento del usuario por email
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: userId)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          _logger.d(
            'UserSubcollectionsService: Usuario encontrado con ID: $userDocId',
          );

          // Ahora buscar la información de situación usando el ID real del usuario
          final doc = await _firestore
              .collection('Users')
              .doc(userDocId)
              .collection('situacion')
              .doc('seleccion')
              .get();

          if (doc.exists) {
            _logger.success(
              'UserSubcollectionsService: Documento de situación encontrado',
            );
            return doc.data();
          } else {
            _logger.w(
              'UserSubcollectionsService: Documento de situación no existe',
            );
          }
        } else {
          _logger.e(
            'UserSubcollectionsService: Usuario no encontrado por email',
          );
        }
      } else {
        // Si userId no es un email, usar directamente como ID
        _logger.d(
          'UserSubcollectionsService: Buscando usuario por ID: $userId',
        );

        final doc = await _firestore
            .collection('Users')
            .doc(userId)
            .collection('situacion')
            .doc('seleccion')
            .get();

        if (doc.exists) {
          return doc.data();
        }
      }

      return null;
    } catch (e, stackTrace) {
      _logger.e('Error obteniendo datos de situación', e, stackTrace);
      return null;
    }
  }

  /// Completa el proceso de onboarding creando subcolecciones y guardando situación final
  Future<void> completeOnboardingProcess(
    String userId,
    Map<String, dynamic> formData,
  ) async {
    try {
      _logger.d('Completando proceso de onboarding para usuario: $userId');

      // Obtener la situación temporal
      final tempSituation = await getTemporarySituation(userId);
      if (tempSituation == null) {
        throw Exception('No se encontró selección temporal de situación');
      }

      // Crear subcolecciones
      await createUserSubcollections(userId);

      // Guardar la situación final con los datos del formulario
      await saveUserSituationWithFormData(userId, tempSituation, formData);

      // Limpiar selección temporal
      await clearTemporarySituation(userId);

      _logger.success('Proceso de onboarding completado exitosamente');
    } catch (e, stackTrace) {
      _logger.e('Error completando proceso de onboarding', e, stackTrace);
      rethrow;
    }
  }

  /// Guarda la situación con los datos del formulario
  Future<void> saveUserSituationWithFormData(
    String userId,
    String situation,
    Map<String, dynamic> formData,
  ) async {
    try {
      final batch = _firestore.batch();

      // Crear documento de selección con todos los datos organizados
      final seleccionRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('situacion')
          .doc('seleccion');

      // Preparar datos base
      final seleccionData = {
        'hasSelectedSituation': true,
        'situationType': situation,
        'onboardingCompleted': true,
        'onboardingCompletedAt': Timestamp.fromDate(DateTime.now()),
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'active',
      };

      // Agregar datos específicos según el tipo de situación
      if (situation == 'preparto') {
        seleccionData.addAll({
          'expectedBirthDate': formData['expectedBirthDate'],
          'formType': 'prepartum',
        });
      } else if (situation == 'postparto') {
        seleccionData.addAll({
          'babyName': formData['babyName'],
          'birthDate': formData['birthDate'],
          'birthTime': formData['birthTime'],
          'birthPlace': formData['birthPlace'],
          'birthWeight': formData['birthWeight'],
          'gestationalAge': formData['gestationalAge'],
          'lastMenstruation': formData['lastMenstruation'],
          'formType': 'postpartum',
        });
      }

      batch.set(seleccionRef, seleccionData);

      await batch.commit();
      _logger.success(
        'Situación con datos de formulario guardada exitosamente: $situation',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error guardando situación con datos de formulario',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
