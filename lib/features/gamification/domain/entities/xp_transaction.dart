import 'package:equatable/equatable.dart';

/// Fuente de XP
enum XPSource {
  lactationRecordQuick, // Registro rápido de lactancia
  lactationRecordComplete, // Registro completo de lactancia
  lessonCompleted, // Lección completada
  babyWeightRecorded, // Registro de peso del bebé
  babySleepRecorded, // Registro de sueño del bebé
  streakBonus, // Bonus por racha
  achievementUnlocked, // Bonus por logro desbloqueado
  restDayUsed, // Bonus por usar día de descanso (positivo, no negativo)
  recordMilestone, // Bonus por alcanzar milestone de registros (10, 25, 50, 100, etc.)
  triviaCompleted, // Bonus por completar trivia después de lección
  dailyChallenge, // Bonus por completar desafío diario
}

/// Transacción de XP - Permite historial, depuración y análisis
class XPTransaction extends Equatable {
  final String id;
  final String userId;
  final int amount; // Cantidad de XP (puede ser negativa en casos especiales)
  final XPSource source; // Fuente del XP
  final String? sourceId; // ID del registro/lección que generó el XP
  final String? bonusReason; // Razón del bonus (ej: "first_of_day", "includes_sleep")
  final DateTime timestamp; // Timestamp CRÍTICO para sincronización offline

  const XPTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.source,
    this.sourceId,
    this.bonusReason,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        source,
        sourceId,
        bonusReason,
        timestamp,
      ];

  XPTransaction copyWith({
    String? id,
    String? userId,
    int? amount,
    XPSource? source,
    String? sourceId,
    String? bonusReason,
    DateTime? timestamp,
  }) {
    return XPTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      bonusReason: bonusReason ?? this.bonusReason,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convierte a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'source': source.name,
      'sourceId': sourceId,
      'bonusReason': bonusReason,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Crea desde Map
  factory XPTransaction.fromMap(Map<String, dynamic> map) {
    return XPTransaction(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: map['amount'] as int,
      source: XPSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => XPSource.lactationRecordQuick,
      ),
      sourceId: map['sourceId'] as String?,
      bonusReason: map['bonusReason'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}

