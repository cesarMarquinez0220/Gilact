# Guía de Implementación de Servicios de Configuración

Este documento explica cómo implementar y usar los servicios de configuración (idioma, sonido, vibración y guardado automático).

## 📋 Servicios Creados

### 1. LocalizationService
Maneja el cambio de idioma de la aplicación.

### 2. SoundService
Maneja la reproducción de sonidos en la aplicación.

### 3. VibrationService
Maneja las vibraciones hápticas en la aplicación.

### 4. AutoSaveService
Maneja el guardado automático de progreso.

---

## 🌍 1. Implementación del Cambio de Idioma

### Configuración en main.dart

El `MaterialApp` ya está configurado para usar `LocalizationService`:

```dart
MaterialApp(
  locale: localizationService.getLocale(),
  supportedLocales: localizationService.getSupportedLocales(),
  // ...
)
```

### Cómo Funciona

1. **El usuario cambia el idioma** en `AppSettingsCardWidget`
2. **Se guarda en SharedPreferences** a través de `SettingsBloc`
3. **El MaterialApp se reconstruye** con el nuevo locale

### Para Aplicar Cambios Inmediatos

Si necesitas que el cambio de idioma se aplique inmediatamente sin reiniciar la app, puedes usar un `StatefulWidget` que escuche cambios:

```dart
// En cualquier widget que necesite reaccionar al cambio de idioma
BlocListener<SettingsBloc, SettingsState>(
  listener: (context, state) {
    if (state is LocalSettingUpdated) {
      // Forzar rebuild del MaterialApp
      // Esto se hace automáticamente si usas un StatefulWidget en main.dart
    }
  },
  child: YourWidget(),
)
```

### Agregar Más Idiomas

Para agregar más idiomas, edita `LocalizationService`:

```dart
Locale getLocale() {
  final languageCode = getCurrentLanguage();
  switch (languageCode) {
    case 'en':
      return const Locale('en', 'US');
    case 'fr':
      return const Locale('fr', 'FR');
    case 'es':
    default:
      return const Locale('es', 'ES');
  }
}
```

---

## 🔊 2. Implementación del Sonido

### Uso Básico

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/sound_service.dart';

// Obtener el servicio
final soundService = GetIt.instance<SoundService>();

// Reproducir sonido de click
await soundService.playClickSound();

// Reproducir sonido de éxito
await soundService.playSuccessSound();

// Reproducir sonido de error
await soundService.playErrorSound();
```

### Ejemplo en un Botón

```dart
ElevatedButton(
  onPressed: () async {
    // Reproducir sonido antes de la acción
    final soundService = GetIt.instance<SoundService>();
    await soundService.playClickSound();
    
    // Tu lógica aquí
    _performAction();
  },
  child: Text('Presionar'),
)
```

### Ejemplo en un Switch

```dart
Switch(
  value: _value,
  onChanged: (newValue) async {
    final soundService = GetIt.instance<SoundService>();
    await soundService.playClickSound();
    
    setState(() {
      _value = newValue;
    });
  },
)
```

### Verificar si el Sonido está Habilitado

```dart
final soundService = GetIt.instance<SoundService>();
if (soundService.isSoundEnabled()) {
  // El sonido está habilitado
  await soundService.playClickSound();
}
```

---

## 📳 3. Implementación de la Vibración

### Uso Básico

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/vibration_service.dart';

// Obtener el servicio
final vibrationService = GetIt.instance<VibrationService>();

// Vibración ligera
await vibrationService.lightImpact();

// Vibración media
await vibrationService.mediumImpact();

// Vibración pesada
await vibrationService.heavyImpact();

// Vibración de selección (para switches, botones)
await vibrationService.selectionClick();
```

### Ejemplo en un Botón

```dart
ElevatedButton(
  onPressed: () async {
    final vibrationService = GetIt.instance<VibrationService>();
    await vibrationService.vibrateOnButtonPress();
    
    // Tu lógica aquí
    _performAction();
  },
  child: Text('Presionar'),
)
```

### Ejemplo Combinando Sonido y Vibración

```dart
ElevatedButton(
  onPressed: () async {
    final soundService = GetIt.instance<SoundService>();
    final vibrationService = GetIt.instance<VibrationService>();
    
    // Reproducir sonido y vibrar simultáneamente
    await Future.wait([
      soundService.playClickSound(),
      vibrationService.vibrateOnButtonPress(),
    ]);
    
    // Tu lógica aquí
    _performAction();
  },
  child: Text('Presionar'),
)
```

### Ejemplo en un Switch

```dart
Switch(
  value: _value,
  onChanged: (newValue) async {
    final vibrationService = GetIt.instance<VibrationService>();
    await vibrationService.selectionClick();
    
    setState(() {
      _value = newValue;
    });
  },
)
```

---

## 💾 4. Implementación del Guardado Automático

### Uso Básico

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/auto_save_service.dart';

// Obtener el servicio
final autoSaveService = GetIt.instance<AutoSaveService>();

// Guardar progreso de video
await autoSaveService.saveVideoProgress(
  videoId: 123,
  lastPosition: 120, // segundos
  totalDuration: 600, // segundos
  progress: 0.2, // 20%
  isCompleted: false,
);

// Guardar progreso de lección
await autoSaveService.saveLessonProgress(
  lessonId: 456,
  progress: 0.75, // 75%
  isCompleted: false,
);
```

### Integración con Video Player

En tu `VideoPlayerWidget`, reemplaza las llamadas directas a `saveVideoProgress`:

```dart
// ANTES
await _progressService.saveVideoProgress(...);

// DESPUÉS
final autoSaveService = GetIt.instance<AutoSaveService>();
await autoSaveService.saveVideoProgress(...);
```

El `AutoSaveService` automáticamente:
- ✅ Verifica si el guardado automático está habilitado
- ✅ Solo guarda si está habilitado
- ✅ Maneja errores silenciosamente

### Ejemplo en Timer Periódico

```dart
Timer.periodic(const Duration(seconds: 30), (timer) async {
  if (_controller != null && _controller!.value.isReady) {
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final progress = position.inSeconds / duration.inSeconds;
    
    final autoSaveService = GetIt.instance<AutoSaveService>();
    await autoSaveService.saveVideoProgress(
      videoId: widget.video.videoId,
      lastPosition: position.inSeconds,
      totalDuration: duration.inSeconds,
      progress: progress,
    );
  }
});
```

### Verificar si el Guardado Automático está Habilitado

```dart
final autoSaveService = GetIt.instance<AutoSaveService>();
if (autoSaveService.isAutoSaveEnabled()) {
  // El guardado automático está habilitado
  await autoSaveService.saveVideoProgress(...);
} else {
  // El usuario deshabilitó el guardado automático
  print('Guardado automático deshabilitado');
}
```

---

## 🔧 Integración Completa

### Ejemplo: Botón con Sonido, Vibración y Guardado

```dart
ElevatedButton(
  onPressed: () async {
    final soundService = GetIt.instance<SoundService>();
    final vibrationService = GetIt.instance<VibrationService>();
    final autoSaveService = GetIt.instance<AutoSaveService>();
    
    // Feedback háptico y sonoro
    await Future.wait([
      soundService.playClickSound(),
      vibrationService.vibrateOnButtonPress(),
    ]);
    
    // Realizar acción
    await _completeVideo();
    
    // Guardar progreso automáticamente
    await autoSaveService.saveVideoProgress(
      videoId: videoId,
      lastPosition: totalDuration,
      totalDuration: totalDuration,
      progress: 1.0,
      isCompleted: true,
    );
    
    // Feedback de éxito
    await Future.wait([
      soundService.playSuccessSound(),
      vibrationService.vibrateOnSuccess(),
    ]);
  },
  child: Text('Completar Video'),
)
```

---

## 📝 Notas Importantes

1. **Todos los servicios verifican automáticamente** si la funcionalidad está habilitada antes de ejecutarse.

2. **Los servicios están registrados en GetIt**, así que puedes obtenerlos en cualquier parte de la app:
   ```dart
   final service = GetIt.instance<ServiceName>();
   ```

3. **Los servicios manejan errores silenciosamente**, no lanzan excepciones que puedan romper la app.

4. **El cambio de idioma requiere reiniciar la app** o usar un StatefulWidget que escuche cambios del bloc.

5. **El guardado automático solo funciona si el usuario está autenticado**.

---

## 🚀 Próximos Pasos

1. **Integrar sonido en botones importantes** (guardar, completar, etc.)
2. **Integrar vibración en interacciones clave** (switches, botones principales)
3. **Reemplazar llamadas directas a saveVideoProgress** con AutoSaveService
4. **Agregar más idiomas** si es necesario
5. **Agregar archivos de localización** (`.arb` files) para textos traducidos

