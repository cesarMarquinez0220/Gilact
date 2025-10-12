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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
    };
  }

  factory LactationRecord.fromMap(Map<String, dynamic> map, String id) {
    return LactationRecord(
      id: id,
      fechaRegistro: DateTime.parse(map['fecha_registro']),
      duracion: Duration(minutes: map['duracion'] ?? 0),
      tipo: LactationType.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => LactationType.breastfeeding,
      ),
      notas: map['notas'],
      lado: map['lado'],
      volumenExtraccion: map['volumen_extraccion'] ?? 0,
      unidadVolumen: map['unidad_volumen'] ?? 'No',
      vecesBiberon: map['veces_biberon'] ?? 0,
      vecesPecho: map['veces_pecho'] ?? 0,
      pechoDado: map['pecho_dado'] ?? 'Ninguna',
      horasSuenoBebe: map['horas_sueno_bebe'] ?? 0,
      unidadSueno: map['unidad_sueno'] ?? 'No',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaRegistroString:
          map['fecha_registro'] ?? DateTime.now().toIso8601String(),
    );
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
