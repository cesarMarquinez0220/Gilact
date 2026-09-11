import 'package:cloud_firestore/cloud_firestore.dart';

class LactationRecord {
  final String id;
  final DateTime fechaRegistro;
  final Duration duracion;
  final LactationType tipo;
  final String? notas;
  final String? lado; // 'left', 'right', 'both'

  // Campos del formulario original
  final int volumenExtraccion;
  final String unidadVolumen; // 'No', 'ml', 'oz'
  final int vecesBiberon;
  final int vecesPecho;
  final String pechoDado; // 'Ninguna', 'Izquierdo', 'Derecho', 'Ambos'
  final int horasSuenoBebe;
  final String unidadSueno; // 'No', 'Hrs', 'Min'

  // Campos adicionales para el calendario
  final DateTime timestamp;
  final String fechaRegistroString; // Para consultas por fecha

  // NUEVO: Identificador de tipo de registro
  final String tipoRegistro; // 'rapido' | 'completo'
  final bool incluyeSueno; // true si tiene datos de sueño

  LactationRecord({
    required this.id,
    required this.fechaRegistro,
    required this.duracion,
    required this.tipo,
    this.notas,
    this.lado,
    this.volumenExtraccion = 0,
    this.unidadVolumen = 'No',
    this.vecesBiberon = 0,
    this.vecesPecho = 0,
    this.pechoDado = 'Ninguna',
    this.horasSuenoBebe = 0,
    this.unidadSueno = 'No',
    required this.timestamp,
    required this.fechaRegistroString,
    this.tipoRegistro = 'completo', // Por defecto
    this.incluyeSueno = false, // Por defecto
  });

  Map<String, dynamic> toMap() {
    return {
      // NO incluir 'id' - Firestore usa el document ID como identificador
      'fecha_registro': fechaRegistroString,
      'duracion': duracion.inMinutes,
      'tipo': tipo.name,
      'notas': notas,
      'lado': lado,
      'volumen_extraccion': volumenExtraccion,
      'unidad_volumen': unidadVolumen,
      'veces_biberon': vecesBiberon,
      'veces_pecho': vecesPecho,
      'pecho_dado': pechoDado,
      'horas_sueno_bebe': horasSuenoBebe,
      'unidad_sueno': unidadSueno,
      'timestamp': timestamp,
      // NUEVO: Identificadores de tipo
      'tipo_registro': tipoRegistro,
      'incluye_sueno': incluyeSueno,
    };
  }

  factory LactationRecord.fromMap(Map<String, dynamic> map, String id) {
    // Determinar el tipo de lactancia basado en los datos disponibles
    LactationType tipo = LactationType.breastfeeding; // Por defecto
    if (map['pecho_dado'] != null && map['pecho_dado'] != 'Ninguna') {
      tipo = LactationType.breastfeeding;
    } else if ((map['volumen_extraccion'] ?? 0) > 0) {
      tipo = LactationType.pumping;
    } else if ((map['veces_biberon'] ?? 0) > 0) {
      tipo = LactationType.bottle;
    }

    // Calcular duración estimada basada en el tipo
    int duracionMinutos = 0;
    if (tipo == LactationType.breastfeeding) {
      duracionMinutos =
          (map['veces_pecho'] ?? 0) * 15; // 15 min por sesión estimada
    } else if (tipo == LactationType.pumping) {
      duracionMinutos =
          (map['volumen_extraccion'] ?? 0) ~/
          10; // 1 min por cada 10ml estimado
    } else if (tipo == LactationType.bottle) {
      duracionMinutos =
          (map['veces_biberon'] ?? 0) * 10; // 10 min por biberón estimado
    }

    return LactationRecord(
      id: id,
      fechaRegistro: DateTime.parse(map['fecha_registro']),
      duracion: Duration(minutes: duracionMinutos),
      tipo: tipo,
      notas: map['notas'],
      lado: map['pecho_dado'], // Usar pecho_dado como lado
      volumenExtraccion: map['volumen_extraccion'] ?? 0,
      unidadVolumen: map['unidad_volumen'] ?? 'No',
      vecesBiberon: map['veces_biberon'] ?? 0,
      vecesPecho: map['veces_pecho'] ?? 0,
      pechoDado: map['pecho_dado'] ?? 'Ninguna',
      horasSuenoBebe: map['horas_sueno_bebe'] ?? 0,
      unidadSueno: map['unidad_sueno'] ?? 'No',
      timestamp: _parseTimestamp(map['timestamp']),
      fechaRegistroString:
          map['fecha_registro'] ?? DateTime.now().toIso8601String(),
      // NUEVO: Leer identificadores
      tipoRegistro: map['tipo_registro'] ?? 'completo',
      incluyeSueno: _parseBool(map['incluye_sueno']),
    );
  }

  /// Parsea timestamp desde diferentes formatos (Firestore Timestamp, DateTime, o int desde SQLite)
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  /// Parsea bool desde diferentes formatos (bool o int 0/1 desde SQLite)
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    return false;
  }

  LactationRecord copyWith({
    String? id,
    DateTime? fechaRegistro,
    Duration? duracion,
    LactationType? tipo,
    String? notas,
    String? lado,
    int? volumenExtraccion,
    String? unidadVolumen,
    int? vecesBiberon,
    int? vecesPecho,
    String? pechoDado,
    int? horasSuenoBebe,
    String? unidadSueno,
    DateTime? timestamp,
    String? fechaRegistroString,
    String? tipoRegistro,
    bool? incluyeSueno,
  }) {
    return LactationRecord(
      id: id ?? this.id,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      duracion: duracion ?? this.duracion,
      tipo: tipo ?? this.tipo,
      notas: notas ?? this.notas,
      lado: lado ?? this.lado,
      volumenExtraccion: volumenExtraccion ?? this.volumenExtraccion,
      unidadVolumen: unidadVolumen ?? this.unidadVolumen,
      vecesBiberon: vecesBiberon ?? this.vecesBiberon,
      vecesPecho: vecesPecho ?? this.vecesPecho,
      pechoDado: pechoDado ?? this.pechoDado,
      horasSuenoBebe: horasSuenoBebe ?? this.horasSuenoBebe,
      unidadSueno: unidadSueno ?? this.unidadSueno,
      timestamp: timestamp ?? this.timestamp,
      fechaRegistroString: fechaRegistroString ?? this.fechaRegistroString,
      tipoRegistro: tipoRegistro ?? this.tipoRegistro,
      incluyeSueno: incluyeSueno ?? this.incluyeSueno,
    );
  }
}

enum LactationType {
  breastfeeding, // Lactancia directa
  pumping, // Extracción
  bottle, // Biberón con leche materna
}

class LactationStats {
  final int totalFeeds;
  final Duration totalDuration;
  final Duration averageDuration;
  final int feedsToday;
  final Duration durationToday;

  LactationStats({
    required this.totalFeeds,
    required this.totalDuration,
    required this.averageDuration,
    required this.feedsToday,
    required this.durationToday,
  });
}
