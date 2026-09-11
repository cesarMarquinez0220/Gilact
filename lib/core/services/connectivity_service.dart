import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para verificar la conectividad de red
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Verifica si hay conexión a internet
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none) && connectivityResult.isNotEmpty;
    } catch (e) {
      // En caso de error, asumir que no hay conexión
      return false;
    }
  }

  /// Stream que emite cambios en el estado de conectividad
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map(
      (result) => !result.contains(ConnectivityResult.none) && result.isNotEmpty,
    );
  }

  /// Verifica si está conectado a WiFi
  Future<bool> isConnectedToWiFi() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e) {
      return false;
    }
  }

  /// Verifica si está conectado a datos móviles
  Future<bool> isConnectedToMobile() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el tipo de conexión actual
  Future<ConnectivityResult> getConnectionType() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.isNotEmpty) {
        return connectivityResult.first;
      }
      return ConnectivityResult.none;
    } catch (e) {
      return ConnectivityResult.none;
    }
  }
}
