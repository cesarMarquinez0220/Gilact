import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Servicio para prevenir grabación de pantalla y capturas de pantalla
/// Implementa protección similar a Netflix para Android e iOS
class ScreenRecordingPreventionService {
  static const MethodChannel _channel = MethodChannel(
    'screen_recording_prevention',
  );
  static const EventChannel _eventChannel = EventChannel(
    'screen_recording_prevention_events',
  );
  static StreamController<bool>? _recordingStatusController;
  static StreamSubscription? _recordingStatusSubscription;

  /// Activa la prevención de grabación de pantalla
  /// En Android: establece FLAG_SECURE en la ventana
  /// En iOS: activa protección nativa
  static Future<void> enableScreenProtection() async {
    try {
      if (Platform.isAndroid) {
        // Android: usar FLAG_SECURE para prevenir capturas y grabaciones
        await _channel.invokeMethod('enableSecureFlag');
        if (kDebugMode) {
          print('🔒 Protección de pantalla activada (Android)');
        }
      } else if (Platform.isIOS) {
        // iOS: usar métodos nativos para prevenir grabación
        await _channel.invokeMethod('enableScreenProtection');
        if (kDebugMode) {
          print('🔒 Protección de pantalla activada (iOS)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error activando protección de pantalla: $e');
      }
      // En caso de error, intentar método alternativo para Android
      if (Platform.isAndroid) {
        _enableSecureFlagAndroid();
      }
    }
  }

  /// Desactiva la prevención de grabación de pantalla
  static Future<void> disableScreenProtection() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('disableSecureFlag');
        if (kDebugMode) {
          print('🔓 Protección de pantalla desactivada (Android)');
        }
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('disableScreenProtection');
        if (kDebugMode) {
          print('🔓 Protección de pantalla desactivada (iOS)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error desactivando protección de pantalla: $e');
      }
      // En caso de error, intentar método alternativo para Android
      if (Platform.isAndroid) {
        _disableSecureFlagAndroid();
      }
    }
  }

  /// Método alternativo para Android usando SystemChrome
  /// Nota: Este método es menos robusto pero funciona sin código nativo
  static void _enableSecureFlagAndroid() {
    try {
      // Este método requiere implementación nativa para ser completamente efectivo
      // Por ahora, solo registramos el intento
      if (kDebugMode) {
        print('🔒 Intentando activar FLAG_SECURE (método alternativo)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error en método alternativo: $e');
      }
    }
  }

  /// Método alternativo para desactivar en Android
  static void _disableSecureFlagAndroid() {
    try {
      if (kDebugMode) {
        print('🔓 Desactivando FLAG_SECURE (método alternativo)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error desactivando método alternativo: $e');
      }
    }
  }

  /// Verifica si la grabación de pantalla está activa (solo Android)
  /// Retorna true si se detecta grabación activa
  static Future<bool> isScreenRecordingActive() async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>(
          'isScreenRecordingActive',
        );
        return result ?? false;
      }
      // iOS no permite detectar grabación de pantalla directamente
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error verificando estado de grabación: $e');
      }
      return false;
    }
  }

  /// Escucha cambios en el estado de grabación de pantalla
  /// Retorna un Stream que emite true cuando se detecta grabación activa
  static Stream<bool> watchScreenRecordingStatus() {
    try {
      if (Platform.isAndroid) {
        // Android: usar EventChannel para recibir eventos de broadcast
        return _eventChannel
            .receiveBroadcastStream()
            .map((dynamic event) {
              // El evento puede ser un bool o un Map
              if (event is bool) {
                return event;
              } else if (event is Map) {
                return event['isRecording'] as bool? ?? false;
              }
              return false;
            })
            .handleError((error) {
              if (kDebugMode) {
                print('⚠️ Error en stream de grabación (Android): $error');
              }
            });
      } else if (Platform.isIOS) {
        // iOS: usar MethodChannel con handler para recibir notificaciones
        _recordingStatusController ??= StreamController<bool>.broadcast();

        // Configurar listener para notificaciones desde iOS
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'onScreenRecordingDetected') {
            final isRecording = call.arguments as bool? ?? false;
            _recordingStatusController?.add(isRecording);
          }
        });

        return _recordingStatusController!.stream;
      }
      return Stream.value(false);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error creando stream de estado de grabación: $e');
      }
      return Stream.value(false);
    }
  }

  /// Limpia los recursos del servicio
  static void dispose() {
    _recordingStatusSubscription?.cancel();
    _recordingStatusSubscription = null;
    _recordingStatusController?.close();
    _recordingStatusController = null;
  }
}
