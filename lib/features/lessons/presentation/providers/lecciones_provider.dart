import 'package:flutter/foundation.dart';

class LeccionesProvider extends ChangeNotifier {
  final Set<int> _leccionesCompletadas = {};
  final Map<int, double> _progresoVideos = {};

  bool isLeccionCompletada(int videoId) {
    return _leccionesCompletadas.contains(videoId);
  }

  double getProgresoVideo(int videoId) {
    return _progresoVideos[videoId] ?? 0.0;
  }

  void marcarLeccionCompletada(int videoId) {
    _leccionesCompletadas.add(videoId);
    _progresoVideos[videoId] = 100.0;
    notifyListeners();
  }

  void actualizarProgresoVideo(int videoId, double progreso) {
    _progresoVideos[videoId] = progreso;
    if (progreso >= 100.0) {
      marcarLeccionCompletada(videoId);
    }
    notifyListeners();
  }

  int getUltimaLeccionCompletada() {
    if (_leccionesCompletadas.isEmpty) return 0;
    return _leccionesCompletadas.reduce((a, b) => a > b ? a : b);
  }

  void imprimirAvancesMap() {
    if (kDebugMode) {
      print('Lecciones completadas: $_leccionesCompletadas');
      print('Progreso videos: $_progresoVideos');
    }
  }
}
