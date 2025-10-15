import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio especializado para manejar las subcolecciones del usuario
@singleton
class UserSubcollectionsService {
  final FirebaseFirestore _firestore;

  UserSubcollectionsService(this._firestore);

  /// Crea las subcolecciones necesarias para un usuario
  Future<void> createUserSubcollections(String userId) async {
    try {
      print(
        '🔧 UserSubcollectionsService: Creando subcolecciones para usuario: $userId',
      );

      // Solo crear subcolección 'situacion' para información de la situación
      await _createSituacionSubcollection(userId);

      // La subcolección 'videos' se creará dinámicamente cuando el usuario pausa por primera vez
      print(
        '✅ UserSubcollectionsService: Subcolección situacion creada exitosamente',
      );
    } catch (e) {
      print('❌ UserSubcollectionsService: Error creando subcolecciones: $e');
      rethrow;
    }
  }

  /// Crea la subcolección 'situacion' para información de la situación
  Future<void> _createSituacionSubcollection(String userId) async {
    // La subcolección se creará automáticamente cuando se agreguen documentos
    print('👶 Subcolección situacion preparada');
  }

  /// Guarda la selección temporal de situación (antes de completar formularios)
  Future<void> saveTemporarySituation(String userId, String situation) async {
    try {
      // Guardar en SharedPreferences como selección temporal
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_situation_$userId', situation);
      print('✅ Selección temporal guardada: $situation');
    } catch (e) {
      print('❌ Error guardando selección temporal: $e');
      rethrow;
    }
  }

  /// Obtiene la selección temporal de situación
  Future<String?> getTemporarySituation(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('temp_situation_$userId');
    } catch (e) {
      print('❌ Error obteniendo selección temporal: $e');
      return null;
    }
  }

  /// Limpia la selección temporal después de completar el proceso
  Future<void> clearTemporarySituation(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_situation_$userId');
      print('✅ Selección temporal limpiada');
    } catch (e) {
      print('❌ Error limpiando selección temporal: $e');
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
      print('✅ Situación guardada exitosamente: $situation');
    } catch (e) {
      print('❌ Error guardando situación: $e');
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
    } catch (e) {
      print('❌ Error verificando subcolecciones: $e');
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
    } catch (e) {
      print('❌ Error obteniendo situación actual: $e');
      return null;
    }
  }

  /// Obtiene todos los datos de la situación del usuario
  Future<Map<String, dynamic>?> getUserSituationData(String userId) async {
    try {
      // Si userId parece ser un email, buscar por email primero
      if (userId.contains('@')) {
        print(
          '🔍 UserSubcollectionsService: Buscando usuario por email: $userId',
        );

        // Buscar el documento del usuario por email
        final userQuery = await _firestore
            .collection('Users')
            .where('email', isEqualTo: userId)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          print(
            '🔍 UserSubcollectionsService: Usuario encontrado con ID: $userDocId',
          );

          // Ahora buscar la información de situación usando el ID real del usuario
          final doc = await _firestore
              .collection('Users')
              .doc(userDocId)
              .collection('situacion')
              .doc('seleccion')
              .get();

          if (doc.exists) {
            print(
              '✅ UserSubcollectionsService: Documento de situación encontrado',
            );
            return doc.data();
          } else {
            print(
              '⚠️ UserSubcollectionsService: Documento de situación no existe',
            );
          }
        } else {
          print('❌ UserSubcollectionsService: Usuario no encontrado por email');
        }
      } else {
        // Si userId no es un email, usar directamente como ID
        print('🔍 UserSubcollectionsService: Buscando usuario por ID: $userId');

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
    } catch (e) {
      print('❌ Error obteniendo datos de situación: $e');
      return null;
    }
  }

  /// Completa el proceso de onboarding creando subcolecciones y guardando situación final
  Future<void> completeOnboardingProcess(
    String userId,
    Map<String, dynamic> formData,
  ) async {
    try {
      print('🎯 Completando proceso de onboarding para usuario: $userId');

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

      print('✅ Proceso de onboarding completado exitosamente');
    } catch (e) {
      print('❌ Error completando proceso de onboarding: $e');
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
      print(
        '✅ Situación con datos de formulario guardada exitosamente: $situation',
      );
    } catch (e) {
      print('❌ Error guardando situación con datos de formulario: $e');
      rethrow;
    }
  }
}
