import '../services/app_logger.dart';
import '../di/injection.dart';

/// Helper para obtener fácilmente una instancia de AppLogger
/// Útil para clases que no tienen acceso directo a GetIt
AppLogger getLogger() {
  try {
    return getIt<AppLogger>();
  } catch (e) {
    // Si GetIt no está disponible, crear una instancia temporal
    // Esto no debería pasar en producción, pero es un fallback seguro
    throw StateError('AppLogger no está disponible. Asegúrate de que configureDependencies() se haya llamado primero.');
  }
}

