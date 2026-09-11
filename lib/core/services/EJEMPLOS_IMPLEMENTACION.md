# Ejemplos Prácticos de Implementación

## 📱 Ejemplo 1: Botón con Sonido y Vibración

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/interactive_button.dart';

// Opción 1: Usar InteractiveButton (recomendado)
InteractiveButton(
  onPressed: () {
    // Tu lógica aquí
    _saveData();
  },
  child: Text('Guardar'),
)

// Opción 2: Implementación manual
ElevatedButton(
  onPressed: () async {
    final soundService = GetIt.instance<SoundService>();
    final vibrationService = GetIt.instance<VibrationService>();
    
    await Future.wait([
      soundService.playClickSound(),
      vibrationService.vibrateOnButtonPress(),
    ]);
    
    _saveData();
  },
  child: Text('Guardar'),
)
```

## 🔄 Ejemplo 2: Switch con Feedback Háptico

```dart
import '../../../../core/widgets/interactive_button.dart';

InteractiveSwitch(
  value: _isEnabled,
  onChanged: (value) {
    setState(() {
      _isEnabled = value;
    });
  },
)
```

## 🎥 Ejemplo 3: Guardado Automático en Video Player

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/auto_save_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  // ...
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final _autoSaveService = GetIt.instance<AutoSaveService>();
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSave();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_controller != null && _controller!.value.isReady) {
        final position = _controller!.value.position;
        final duration = _controller!.value.duration;
        final progress = position.inSeconds / duration.inSeconds;
        
        // El servicio verifica automáticamente si está habilitado
        _autoSaveService.saveVideoProgress(
          videoId: widget.video.videoId,
          lastPosition: position.inSeconds,
          totalDuration: duration.inSeconds,
          progress: progress,
          isCompleted: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
```

## 🌍 Ejemplo 4: Cambio de Idioma con Rebuild

Para que el cambio de idioma se aplique inmediatamente, puedes usar este patrón:

```dart
// En profile_settings_page.dart
void _handleSettingChanged(String key, dynamic value) {
  context.read<SettingsBloc>().add(
    UpdateLocalSettingRequested(key: key, value: value),
  );
  
  if (key == 'language') {
    // Forzar rebuild del MaterialApp
    // Esto se hace automáticamente si el MaterialApp está dentro de un Builder
    // que escucha cambios del LocalizationService
  }
}
```

## 🎯 Ejemplo 5: Integración Completa en un Formulario

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/services/auto_save_service.dart';
import '../../../../core/widgets/interactive_button.dart';

class MyForm extends StatefulWidget {
  // ...
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _soundService = GetIt.instance<SoundService>();
  final _vibrationService = GetIt.instance<VibrationService>();
  final _autoSaveService = GetIt.instance<AutoSaveService>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            // ...
            onChanged: (value) {
              // Guardar automáticamente mientras el usuario escribe
              _autoSaveDraft();
            },
          ),
          const SizedBox(height: 20),
          InteractiveButton(
            onPressed: _submitForm,
            child: Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _autoSaveDraft() async {
    // Guardar borrador automáticamente
    await _autoSaveService.saveGenericData(
      collection: 'drafts',
      documentId: 'current',
      data: {
        'field1': _field1Controller.text,
        'field2': _field2Controller.text,
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Feedback háptico y sonoro
      await Future.wait([
        _soundService.playClickSound(),
        _vibrationService.vibrateOnButtonPress(),
      ]);
      
      // Guardar datos finales
      await _saveFinalData();
      
      // Feedback de éxito
      await Future.wait([
        _soundService.playSuccessSound(),
        _vibrationService.vibrateOnSuccess(),
      ]);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos guardados exitosamente')),
      );
    } else {
      // Feedback de error
      await Future.wait([
        _soundService.playErrorSound(),
        _vibrationService.vibrateOnError(),
      ]);
    }
  }
}
```

## 🔔 Ejemplo 6: Notificación con Sonido y Vibración

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';

void showNotificationWithFeedback(String message) async {
  final soundService = GetIt.instance<SoundService>();
  final vibrationService = GetIt.instance<VibrationService>();
  
  // Feedback antes de mostrar la notificación
  await Future.wait([
    soundService.playAlertSound(),
    vibrationService.mediumImpact(),
  ]);
  
  // Mostrar SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

## 📝 Notas Importantes

1. **Todos los servicios verifican automáticamente** si están habilitados antes de ejecutarse.

2. **Usa `InteractiveButton` y `InteractiveSwitch`** para simplificar la implementación.

3. **El guardado automático solo funciona si el usuario está autenticado**.

4. **El cambio de idioma requiere que el MaterialApp esté dentro de un Builder** que pueda reconstruirse.

5. **Los servicios están disponibles globalmente** a través de `GetIt.instance<ServiceName>()`.

