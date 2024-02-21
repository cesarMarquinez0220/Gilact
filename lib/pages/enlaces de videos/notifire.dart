import 'package:flutter/material.dart';

class LeccionesProvider with ChangeNotifier {
  int _lastCompletedLesson = 0;
  // ignore: non_constant_identifier_names
  Map<int, bool> lecciones_list = {
    1: true, //video 1
    2: false, //video 2.1
    3: false, //video 2.2
    4: false, //video 3.1
    5: false, //video 3.2
    6: false, //video 3.3
    7: false, //video 3.4
    8: false, //video 4.1
    9: false, //video 4.2
    10: false, //video 5
    11: false, //video 6
    12: false, //video 7
    13: false, //video 8.1
    14: false, //video 8.2
    15: false, //video 9
    16: false, //video 10
    17: false, //video 11.1
    18: false, //video 11.2
    19: false, //video 11.3
    20: false, //video 11.4
    21: false, //video 11.5
    22: false, //video 12
    23: false, //video 13.1
    24: false, //video 13.2
    25: false, //video 13.3
    26: false, //video 14.1
    27: false, //video 14.2
    28: false, //video 15
    29: false, //video 16
  };
  int get lastCompletedLesson => _lastCompletedLesson;

  void updateLastCompletedLesson(int lessonNumber) {
    _lastCompletedLesson = lessonNumber;
    notifyListeners();
  }

  void marcarVideoComoVisto(int id) {
    if (lecciones_list.containsKey(id)) {
      lecciones_list[id] = true; // Marcar el video actual como visto
      // Actualizar el estado del siguiente video si existe
      int siguienteId = id + 1;
      if (lecciones_list.containsKey(siguienteId)) {
        lecciones_list[siguienteId] = true;
      }
      notifyListeners(); // Notificar a los oyentes que el estado ha cambiado
    }
  }

  bool isLeccionCompletada(int leccionId) {
    return lecciones_list[leccionId] ?? false;
  }

  void updateVideosVistos(List<bool> videosVistos) {
    // Actualizar la lista de videos vistos con la nueva información
    for (int i = 0; i < videosVistos.length; i++) {
      lecciones_list[i + 1] = videosVistos[i];
      // Marcar el siguiente video como visto si el video actual está marcado como visto
      if (videosVistos[i]) {
        int siguienteId = i + 2; // Obtener el ID del siguiente video
        if (lecciones_list.containsKey(siguienteId)) {
          lecciones_list[siguienteId] = true;
        }
      }
    }
    notifyListeners(); // Notificar a los oyentes que el estado ha cambiado
  }

  int ultimoIdEnEstadoTrue(Map<int, bool> lecciones_list) {
    int? ultimoId;
    lecciones_list.forEach((id, estado) {
      if (estado) {
        ultimoId = id;
      }
    });
    return ultimoId ?? -1;
  }
}
