import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Estrategias de resolución de conflictos
enum ConflictResolutionStrategy {
  lastWriteWins, // Última escritura gana (por defecto)
  merge, // Merge inteligente (para casos específicos)
  userDecision, // Usuario decide (para conflictos críticos)
}

/// Información sobre un conflicto detectado
class ConflictInfo {
  final String localId;
  final String? firestoreId;
  final String collectionPath;
  final Map<String, dynamic> localData;
  final Map<String, dynamic>? remoteData;
  final DateTime localLastModified;
  final DateTime? remoteLastModified;
  final ConflictResolutionStrategy strategy;

  ConflictInfo({
    required this.localId,
    this.firestoreId,
    required this.collectionPath,
    required this.localData,
    this.remoteData,
    required this.localLastModified,
    this.remoteLastModified,
    this.strategy = ConflictResolutionStrategy.lastWriteWins,
  });
}

/// Servicio para detectar y resolver conflictos de sincronización
class ConflictResolutionService {
  static final ConflictResolutionService _instance =
      ConflictResolutionService._internal();
  factory ConflictResolutionService() => _instance;
  ConflictResolutionService._internal();

  /// Detecta si hay un conflicto entre datos locales y remotos
  Future<ConflictInfo?> detectConflict({
    required String localId,
    String? firestoreId,
    required String collectionPath,
    required Map<String, dynamic> localData,
    required DateTime localLastModified,
    required FirebaseFirestore firestore,
    required String userDocId,
  }) async {
    try {
      // Si no hay firestoreId, no hay conflicto (es un registro nuevo)
      if (firestoreId == null) {
        return null;
      }

      // Obtener datos remotos
      final remoteDoc = await _getRemoteDocument(
        firestore,
        userDocId,
        collectionPath,
        firestoreId,
      );

      if (remoteDoc == null || !remoteDoc.exists) {
        // El documento no existe en Firestore, no hay conflicto
        return null;
      }

      final remoteData = remoteDoc.data() as Map<String, dynamic>?;
      if (remoteData == null) {
        return null;
      }

      // Obtener timestamp de última modificación remota
      final remoteLastModified = _extractLastModified(remoteData);
      final localLastModifiedTimestamp = localLastModified.millisecondsSinceEpoch;
      final remoteLastModifiedTimestamp =
          remoteLastModified?.millisecondsSinceEpoch ?? 0;

      // Verificar si hay conflicto (ambos fueron modificados)
      // Un conflicto existe si:
      // 1. El documento remoto fue modificado después de la última sincronización local
      // 2. Y el documento local también fue modificado
      final hasConflict = remoteLastModifiedTimestamp > localLastModifiedTimestamp;

      if (!hasConflict) {
        return null;
      }

      if (kDebugMode) {
        print(
          '⚠️ ConflictResolutionService: Conflicto detectado para $localId en $collectionPath',
        );
        print(
          '   Local modificado: $localLastModifiedTimestamp',
        );
        print(
          '   Remoto modificado: $remoteLastModifiedTimestamp',
        );
      }

      return ConflictInfo(
        localId: localId,
        firestoreId: firestoreId,
        collectionPath: collectionPath,
        localData: localData,
        remoteData: remoteData,
        localLastModified: localLastModified,
        remoteLastModified: remoteLastModified,
        strategy: _determineStrategy(collectionPath),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ConflictResolutionService: Error detectando conflicto: $e');
      }
      return null;
    }
  }

  /// Resuelve un conflicto usando la estrategia determinada
  Future<Map<String, dynamic>> resolveConflict(ConflictInfo conflict) async {
    switch (conflict.strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        return _resolveLastWriteWins(conflict);
      case ConflictResolutionStrategy.merge:
        return _resolveMerge(conflict);
      case ConflictResolutionStrategy.userDecision:
        // Por ahora, usar Last Write Wins como fallback
        // En el futuro, se podría mostrar un diálogo al usuario
        return _resolveLastWriteWins(conflict);
    }
  }

  /// Resuelve conflicto usando Last Write Wins (última escritura gana)
  Map<String, dynamic> _resolveLastWriteWins(ConflictInfo conflict) {
    final localTimestamp = conflict.localLastModified.millisecondsSinceEpoch;
    final remoteTimestamp =
        conflict.remoteLastModified?.millisecondsSinceEpoch ?? 0;

    if (kDebugMode) {
      print(
        '🔄 ConflictResolutionService: Resolviendo conflicto con Last Write Wins',
      );
      print(
        '   Local: $localTimestamp, Remoto: $remoteTimestamp',
      );
    }

    // Si la versión local es más reciente, usar local
    if (localTimestamp > remoteTimestamp) {
      if (kDebugMode) {
        print('   ✅ Usando versión local (más reciente)');
      }
      return conflict.localData;
    } else {
      // Si la versión remota es más reciente, usar remota
      if (kDebugMode) {
        print('   ✅ Usando versión remota (más reciente)');
      }
      return conflict.remoteData ?? conflict.localData;
    }
  }

  /// Resuelve conflicto usando merge inteligente
  Map<String, dynamic> _resolveMerge(ConflictInfo conflict) {
    if (kDebugMode) {
      print('🔄 ConflictResolutionService: Resolviendo conflicto con Merge');
    }

    final merged = Map<String, dynamic>.from(conflict.remoteData ?? {});
    
    // Para registros de lactancia y sueño, priorizar campos específicos
    if (conflict.collectionPath == 'lactancia' ||
        conflict.collectionPath == 'sueno_diario') {
      // Merge: usar datos remotos como base, pero preservar algunos campos locales
      // Por ejemplo, preservar notas locales si las hay
      if (conflict.localData.containsKey('notas') &&
          conflict.localData['notas'] != null &&
          (conflict.localData['notas'] as String).isNotEmpty) {
        merged['notas'] = conflict.localData['notas'];
      }
      
      // Usar la fecha de modificación más reciente
      final localTimestamp = conflict.localLastModified.millisecondsSinceEpoch;
      final remoteTimestamp =
          conflict.remoteLastModified?.millisecondsSinceEpoch ?? 0;
      
      if (localTimestamp > remoteTimestamp) {
        merged['updated_at'] = conflict.localLastModified.toIso8601String();
      }
    }

    return merged;
  }

  /// Determina la estrategia de resolución según el tipo de colección
  ConflictResolutionStrategy _determineStrategy(String collectionPath) {
    // Para registros de lactancia y sueño, usar Last Write Wins
    if (collectionPath == 'lactancia' || collectionPath == 'sueno_diario') {
      return ConflictResolutionStrategy.lastWriteWins;
    }
    
    // Por defecto, usar Last Write Wins
    return ConflictResolutionStrategy.lastWriteWins;
  }

  /// Obtiene un documento remoto de Firestore
  Future<DocumentSnapshot?> _getRemoteDocument(
    FirebaseFirestore firestore,
    String userDocId,
    String collectionPath,
    String documentId,
  ) async {
    try {
      CollectionReference collection;
      
      if (collectionPath == 'lactancia') {
        collection = firestore
            .collection('Users')
            .doc(userDocId)
            .collection('situacion')
            .doc('seleccion')
            .collection('lactancia');
      } else if (collectionPath == 'sueno_diario') {
        collection = firestore
            .collection('Users')
            .doc(userDocId)
            .collection('situacion')
            .doc('seleccion')
            .collection('sueno_diario');
      } else {
        return null;
      }

      return await collection.doc(documentId).get();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ConflictResolutionService: Error obteniendo documento remoto: $e');
      }
      return null;
    }
  }

  /// Extrae la fecha de última modificación de los datos
  DateTime? _extractLastModified(Map<String, dynamic> data) {
    try {
      // Intentar diferentes campos comunes para timestamp
      if (data.containsKey('updated_at')) {
        final updatedAt = data['updated_at'];
        if (updatedAt is String) {
          return DateTime.tryParse(updatedAt);
        } else if (updatedAt is Timestamp) {
          return updatedAt.toDate();
        }
      }
      
      if (data.containsKey('last_modified')) {
        final lastModified = data['last_modified'];
        if (lastModified is String) {
          return DateTime.tryParse(lastModified);
        } else if (lastModified is Timestamp) {
          return lastModified.toDate();
        }
      }
      
      if (data.containsKey('timestamp')) {
        final timestamp = data['timestamp'];
        if (timestamp is Timestamp) {
          return timestamp.toDate();
        }
      }
      
      if (data.containsKey('created_at')) {
        final createdAt = data['created_at'];
        if (createdAt is String) {
          return DateTime.tryParse(createdAt);
        } else if (createdAt is Timestamp) {
          return createdAt.toDate();
        }
      }

      // Si no se encuentra, usar la fecha actual
      return DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ ConflictResolutionService: Error extrayendo lastModified: $e');
      }
      return DateTime.now();
    }
  }
}

