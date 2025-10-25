import 'package:equatable/equatable.dart';

/// Entidad para representar un registro de sueño del bebé
class SleepRecord extends Equatable {
  final String id;
  final String userId;
  final DateTime sleepStartTime;
  final DateTime sleepEndTime;
  final Duration totalSleepDuration;
  final SleepQuality quality;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SleepRecord({
    required this.id,
    required this.userId,
    required this.sleepStartTime,
    required this.sleepEndTime,
    required this.totalSleepDuration,
    required this.quality,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    sleepStartTime,
    sleepEndTime,
    totalSleepDuration,
    quality,
    notes,
    createdAt,
    updatedAt,
  ];

  SleepRecord copyWith({
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
    return SleepRecord(
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

  /// Calcular duración total del sueño
  Duration get sleepDuration => sleepEndTime.difference(sleepStartTime);

  /// Verificar si el registro es de hoy
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(
      sleepStartTime.year,
      sleepStartTime.month,
      sleepStartTime.day,
    );
    return recordDate.isAtSameMomentAs(today);
  }

  /// Obtener hora de inicio formateada
  String get formattedStartTime {
    return '${sleepStartTime.hour.toString().padLeft(2, '0')}:${sleepStartTime.minute.toString().padLeft(2, '0')}';
  }

  /// Obtener hora de fin formateada
  String get formattedEndTime {
    return '${sleepEndTime.hour.toString().padLeft(2, '0')}:${sleepEndTime.minute.toString().padLeft(2, '0')}';
  }

  /// Obtener duración formateada
  String get formattedDuration {
    final hours = totalSleepDuration.inHours;
    final minutes = totalSleepDuration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

/// Calidad del sueño
enum SleepQuality {
  excellent('Excelente'),
  good('Bueno'),
  fair('Regular'),
  poor('Pobre');

  const SleepQuality(this.displayName);
  final String displayName;

  /// Obtener emoji para la calidad
  String get emoji {
    switch (this) {
      case SleepQuality.excellent:
        return '😴';
      case SleepQuality.good:
        return '😊';
      case SleepQuality.fair:
        return '😐';
      case SleepQuality.poor:
        return '😔';
    }
  }

  /// Obtener color para la calidad
  int get colorValue {
    switch (this) {
      case SleepQuality.excellent:
        return 0xFF4CAF50; // Verde
      case SleepQuality.good:
        return 0xFF8BC34A; // Verde claro
      case SleepQuality.fair:
        return 0xFFFFC107; // Amarillo
      case SleepQuality.poor:
        return 0xFFF44336; // Rojo
    }
  }
}

/// Estadísticas de sueño
class SleepStatistics extends Equatable {
  final int totalSleepRecords;
  final Duration totalSleepTime;
  final Duration averageSleepDuration;
  final Map<SleepQuality, int> qualityDistribution;
  final List<SleepRecord> recentRecords;
  final DateTime periodStart;
  final DateTime periodEnd;

  const SleepStatistics({
    required this.totalSleepRecords,
    required this.totalSleepTime,
    required this.averageSleepDuration,
    required this.qualityDistribution,
    required this.recentRecords,
    required this.periodStart,
    required this.periodEnd,
  });

  @override
  List<Object?> get props => [
    totalSleepRecords,
    totalSleepTime,
    averageSleepDuration,
    qualityDistribution,
    recentRecords,
    periodStart,
    periodEnd,
  ];

  /// Obtener calidad más común
  SleepQuality get mostCommonQuality {
    if (qualityDistribution.isEmpty) return SleepQuality.good;

    return qualityDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Obtener tiempo total de sueño formateado
  String get formattedTotalSleepTime {
    final hours = totalSleepTime.inHours;
    final minutes = totalSleepTime.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Obtener duración promedio formateada
  String get formattedAverageDuration {
    final hours = averageSleepDuration.inHours;
    final minutes = averageSleepDuration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
