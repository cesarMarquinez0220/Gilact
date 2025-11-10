import 'package:equatable/equatable.dart';

/// Entidad para representar un registro de peso del bebé
class BabyWeightRecord extends Equatable {
  final String id;
  final String userId;
  final double weight; // Peso en kilogramos
  final DateTime recordedAt; // Fecha y hora del registro
  final String? notes; // Notas opcionales
  final DateTime createdAt;
  final DateTime updatedAt;

  const BabyWeightRecord({
    required this.id,
    required this.userId,
    required this.weight,
    required this.recordedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        weight,
        recordedAt,
        notes,
        createdAt,
        updatedAt,
      ];

  BabyWeightRecord copyWith({
    String? id,
    String? userId,
    double? weight,
    DateTime? recordedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BabyWeightRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verificar si el registro es de hoy
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(
      recordedAt.year,
      recordedAt.month,
      recordedAt.day,
    );
    return recordDate.isAtSameMomentAs(today);
  }

  /// Obtener peso formateado
  String get formattedWeight {
    return '${weight.toStringAsFixed(2)} kg';
  }

  /// Obtener fecha formateada
  String get formattedDate {
    return '${recordedAt.day}/${recordedAt.month}/${recordedAt.year}';
  }

  /// Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'recorded_at': recordedAt.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crear desde mapa de Firestore
  factory BabyWeightRecord.fromMap(Map<String, dynamic> map) {
    return BabyWeightRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      weight: (map['weight'] as num).toDouble(),
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

