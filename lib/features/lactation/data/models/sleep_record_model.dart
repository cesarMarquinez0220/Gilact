import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sleep_record.dart';

/// Modelo de datos para registros de sueño en Firestore
class SleepRecordModel extends SleepRecord {
  const SleepRecordModel({
    required super.id,
    required super.userId,
    required super.sleepStartTime,
    required super.sleepEndTime,
    required super.totalSleepDuration,
    required super.quality,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crear modelo desde documento de Firestore
  factory SleepRecordModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SleepRecordModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sleepStartTime: (data['sleepStartTime'] as Timestamp).toDate(),
      sleepEndTime: (data['sleepEndTime'] as Timestamp).toDate(),
      totalSleepDuration: Duration(
        hours: data['totalSleepHours'] ?? 0,
        minutes: data['totalSleepMinutes'] ?? 0,
      ),
      quality: SleepQuality.values.firstWhere(
        (q) => q.name == data['quality'],
        orElse: () => SleepQuality.good,
      ),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Crear modelo desde mapa de datos
  factory SleepRecordModel.fromMap(Map<String, dynamic> data) {
    return SleepRecordModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      sleepStartTime: data['sleepStartTime'] is Timestamp
          ? (data['sleepStartTime'] as Timestamp).toDate()
          : DateTime.parse(data['sleepStartTime']),
      sleepEndTime: data['sleepEndTime'] is Timestamp
          ? (data['sleepEndTime'] as Timestamp).toDate()
          : DateTime.parse(data['sleepEndTime']),
      totalSleepDuration: Duration(
        hours: data['totalSleepHours'] ?? 0,
        minutes: data['totalSleepMinutes'] ?? 0,
      ),
      quality: SleepQuality.values.firstWhere(
        (q) => q.name == data['quality'],
        orElse: () => SleepQuality.good,
      ),
      notes: data['notes'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data['updatedAt']),
    );
  }

  /// Convertir a documento de Firestore
  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'sleepStartTime': Timestamp.fromDate(sleepStartTime),
      'sleepEndTime': Timestamp.fromDate(sleepEndTime),
      'totalSleepHours': totalSleepDuration.inHours,
      'totalSleepMinutes': totalSleepDuration.inMinutes % 60,
      'quality': quality.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'sleepStartTime': sleepStartTime.toIso8601String(),
      'sleepEndTime': sleepEndTime.toIso8601String(),
      'totalSleepHours': totalSleepDuration.inHours,
      'totalSleepMinutes': totalSleepDuration.inMinutes % 60,
      'quality': quality.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crear nuevo registro de sueño
  factory SleepRecordModel.create({
    required String userId,
    required DateTime sleepStartTime,
    required DateTime sleepEndTime,
    required SleepQuality quality,
    String? notes,
  }) {
    final now = DateTime.now();
    final duration = sleepEndTime.difference(sleepStartTime);

    return SleepRecordModel(
      id: '', // Se asignará al guardar en Firestore
      userId: userId,
      sleepStartTime: sleepStartTime,
      sleepEndTime: sleepEndTime,
      totalSleepDuration: duration,
      quality: quality,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  SleepRecordModel copyWith({
    String? id,
    String? userId,
    DateTime? sleepStartTime,
    DateTime? sleepEndTime,
    Duration? totalSleepDuration,
    SleepQuality? quality,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
      totalSleepDuration: totalSleepDuration ?? this.totalSleepDuration,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
