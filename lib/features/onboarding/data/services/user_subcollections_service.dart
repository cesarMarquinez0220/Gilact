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
  /// También puede usarse para actualizar de preparto a postparto
  Future<void> completeOnboardingProcess(
    String userId,
    Map<String, dynamic> formData,
  ) async {
    try {
      _logger.d('Completando proceso de onboarding para usuario: $userId');

      // Verificar si es un onboarding nuevo o una actualización
      final existingSituation = await getUserCurrentSituation(userId);
      final tempSituation = await getTemporarySituation(userId);
      
      String situationToUse;
      bool isUpdate = false;

      if (existingSituation == 'preparto' && formData['formType'] == 'postpartum') {
        // Es una actualización de preparto a postparto
        _logger.d('Detectada actualización de preparto a postparto');
        situationToUse = 'postparto';
        isUpdate = true;
      } else if (tempSituation != null) {
        // Es un onboarding nuevo con selección temporal
        _logger.d('Onboarding nuevo con selección temporal: $tempSituation');
        situationToUse = tempSituation;
      } else {
        // Intentar inferir la situación del tipo de formulario
        if (formData['formType'] == 'postpartum') {
          situationToUse = 'postparto';
          _logger.d('Inferida situación postparto desde formType');
        } else if (formData['formType'] == 'prepartum') {
          situationToUse = 'preparto';
          _logger.d('Inferida situación preparto desde formType');
        } else {
          throw Exception('No se encontró selección temporal de situación y no se pudo inferir del formulario');
        }
      }

      // Crear subcolecciones si no existen
      final hasSubcollections = await this.hasSubcollections(userId);
      if (!hasSubcollections) {
        _logger.d('Creando subcolecciones para usuario: $userId');
        await createUserSubcollections(userId);
      } else {
        _logger.d('Subcolecciones ya existen para usuario: $userId');
      }

      // Guardar la situación final con los datos del formulario
      await saveUserSituationWithFormData(userId, situationToUse, formData);

      // Limpiar selección temporal si existe
      if (tempSituation != null) {
        await clearTemporarySituation(userId);
      }

      _logger.success('Proceso de onboarding completado exitosamente (${isUpdate ? "actualización" : "nuevo"})');
    } catch (e, stackTrace) {
      _logger.e('Error completando proceso de onboarding', e, stackTrace);
      rethrow;
    }
  }

  /// Guarda la situación con los datos del formulario
  /// Si el documento ya existe, lo actualiza; si no, lo crea
  /// Preserva la información original cuando se actualiza de preparto a postparto
  Future<void> saveUserSituationWithFormData(
    String userId,
    String situation,
    Map<String, dynamic> formData,
  ) async {
    try {
      final seleccionRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('situacion')
          .doc('seleccion');

      // Verificar si el documento ya existe
      final existingDoc = await seleccionRef.get();
      final existingData = existingDoc.data();
      final isUpdate = existingDoc.exists;
      final wasPrepartum = existingData != null && 
                          existingData['situationType'] == 'preparto';
      final isUpdatingToPostpartum = isUpdate && 
                                     wasPrepartum && 
                                     situation == 'postparto';

      // Preparar datos base
      final seleccionData = <String, dynamic>{
        'hasSelectedSituation': true,
        'situationType': situation,
        'onboardingCompleted': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'active',
      };

      // Si es un documento nuevo, agregar createdAt y onboardingCompletedAt
      if (!isUpdate) {
        seleccionData.addAll({
          'onboardingCompletedAt': Timestamp.fromDate(DateTime.now()),
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // Si es una actualización, preservar createdAt si existe
        if (existingData != null && existingData['createdAt'] != null) {
          seleccionData['createdAt'] = existingData['createdAt'];
        } else {
          seleccionData['createdAt'] = Timestamp.fromDate(DateTime.now());
        }
        
        // Si es una actualización de preparto a postparto, preservar información original
        if (isUpdatingToPostpartum) {
          _logger.d('Preservando información de preparto al actualizar a postparto');
          
          // Preservar datos originales de preparto de forma simple
          if (existingData != null) {
            // Guardar solo la información esencial de preparto
            seleccionData['prepartumData'] = {
              'expectedBirthDate': existingData['expectedBirthDate'],
            };
            
            // Fecha cuando se registró el bebé (momento de la actualización)
            seleccionData['babyRegisteredAt'] = Timestamp.fromDate(DateTime.now());
            
            _logger.d('Información de preparto preservada: ${seleccionData['prepartumData']}');
          }
        }
      }

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

      // Usar set con merge: false para reemplazar completamente
      // (pero ya preservamos los datos importantes arriba)
      await seleccionRef.set(seleccionData, SetOptions(merge: false));

      _logger.success(
        'Situación con datos de formulario ${isUpdate ? "actualizada" : "guardada"} exitosamente: $situation',
      );
      
      if (isUpdatingToPostpartum) {
        _logger.success(
          'Actualización de preparto a postparto completada. Información original preservada.',
        );
      }
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
