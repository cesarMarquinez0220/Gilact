# 🎵 Estrategia de Implementación: Sonido y Vibraciones en GuiLact

## 📋 Análisis del Proyecto

Después de analizar todo el proyecto GuiLact, aquí está la estrategia completa para implementar sonido y vibraciones de manera coherente y efectiva.

---

## 🎮 1. GAMIFICACIÓN (Prioridad ALTA)

### Ubicaciones Clave:

#### 1.1. Ganancia de XP
**Archivo:** `lib/features/gamification/presentation/widgets/xp_celebration_animation.dart`

**Cuándo:** Cada vez que se muestra la animación de celebración de XP

**Implementación:**
```dart
// En el método show() o en el build()
static void show(BuildContext context, int xpAmount, {VoidCallback? onComplete}) {
  final soundService = GetIt.instance<SoundService>();
  final vibrationService = GetIt.instance<VibrationService>();
  
  // Sonido de éxito + vibración ligera
  Future.wait([
    soundService.playSuccessSound(),
    vibrationService.lightImpact(),
  ]);
  
  // ... resto del código
}
```

#### 1.2. Logro Desbloqueado
**Archivo:** `lib/features/gamification/presentation/widgets/achievement_unlocked_dialog.dart`

**Cuándo:** Cuando se muestra el diálogo de logro desbloqueado

**Implementación:**
```dart
static void show(BuildContext context, Achievement achievement, int xpReward) {
  final soundService = GetIt.instance<SoundService>();
  final vibrationService = GetIt.instance<VibrationService>();
  
  // Sonido de alerta especial + vibración media (más fuerte que XP normal)
  Future.wait([
    soundService.playAlertSound(),
    vibrationService.mediumImpact(),
  ]);
  
  showDialog(...);
}
```

#### 1.3. Subida de Nivel
**Archivo:** `lib/features/gamification/presentation/bloc/gamification_bloc.dart`

**Cuándo:** En el método `_onAddXP` cuando `leveledUp` es `true`

**Implementación:**
```dart
if (leveledUp) {
  final soundService = GetIt.instance<SoundService>();
  final vibrationService = GetIt.instance<VibrationService>();
  
  // Sonido especial de nivel + vibración pesada
  Future.wait([
    soundService.playSuccessSound(), // O un sonido especial de nivel
    vibrationService.heavyImpact(),
  ]);
}
```

#### 1.4. Bonus de Racha
**Archivo:** `lib/features/gamification/presentation/bloc/gamification_bloc.dart`

**Cuándo:** Cuando se detecta un bonus de racha (3, 7, 30, 60, 100 días)

**Implementación:**
```dart
if (updatedStreak.currentStreak == 3 || updatedStreak.currentStreak == 7 || ...) {
  final soundService = GetIt.instance<SoundService>();
  final vibrationService = GetIt.instance<VibrationService>();
  
  // Sonido especial + vibración media
  Future.wait([
    soundService.playAlertSound(),
    vibrationService.mediumImpact(),
  ]);
}
```

---

## 🍼 2. LACTACIÓN (Prioridad ALTA)

### Ubicaciones Clave:

#### 2.1. Registro Rápido de Lactación
**Archivo:** `lib/features/lactation/presentation/widgets/quick_lactation_dialog.dart`

**Cuándo:** Cuando se guarda exitosamente un registro rápido

**Implementación:**
```dart
// Después de guardar exitosamente
final soundService = GetIt.instance<SoundService>();
final vibrationService = GetIt.instance<VibrationService>();

await Future.wait([
  soundService.playSuccessSound(),
  vibrationService.vibrateOnSuccess(),
]);
```

#### 2.2. Registro Completo de Lactación
**Archivo:** `lib/features/lactation/presentation/pages/lactation_record_page.dart` o `lactation_flow_page_enhanced.dart`

**Cuándo:** Cuando se completa y guarda un registro completo

**Implementación:**
```dart
// Al finalizar el flujo de registro
final soundService = GetIt.instance<SoundService>();
final vibrationService = GetIt.instance<VibrationService>();

await Future.wait([
  soundService.playSuccessSound(),
  vibrationService.vibrateOnSuccess(),
]);
```

#### 2.3. Botón Inteligente de Lactación
**Archivo:** `lib/features/lactation/presentation/widgets/smart_lactation_button.dart`

**Cuándo:** Al presionar el botón principal de lactación

**Implementación:**
```dart
// Reemplazar ElevatedButton con InteractiveButton
InteractiveButton(
  onPressed: () {
    // Lógica existente
  },
  child: Text('Registrar Lactación'),
)
```

#### 2.4. Registro de Peso del Bebé
**Archivo:** `lib/features/lactation/presentation/pages/baby_weight_form_page.dart`

**Cuándo:** Cuando se guarda exitosamente un registro de peso

**Implementación:**
```dart
// Después de guardar
final soundService = GetIt.instance<SoundService>();
final vibrationService = GetIt.instance<VibrationService>();

await Future.wait([
  soundService.playSuccessSound(),
  vibrationService.vibrateOnSuccess(),
]);
```

#### 2.5. Registro de Sueño
**Archivo:** `lib/features/lactation/presentation/pages/daily_sleep_form_page.dart`

**Cuándo:** Cuando se guarda exitosamente un registro de sueño

**Implementación:**
```dart
// Después de guardar
final soundService = GetIt.instance<SoundService>();
final vibrationService = GetIt.instance<VibrationService>();

await Future.wait([
  soundService.playSuccessSound(),
  vibrationService.vibrateOnSuccess(),
]);
```

---

## 📚 3. LECCIONES (Prioridad MEDIA)

### Ubicaciones Clave:

#### 3.1. Completar Lección
**Archivo:** `lib/features/lessons/presentation/pages/lesson_videos_page.dart`

**Cuándo:** Cuando se completa una lección (todos los videos vistos)

**Implementación:**
```dart
// Cuando se detecta que la lección está completa
final soundService = GetIt.instance<SoundService>();
final vibrationService = GetIt.instance<VibrationService>();

await Future.wait([
  soundService.playSuccessSound(),
  vibrationService.mediumImpact(),
]);
```

#### 3.2. Completar Video
**Archivo:** `lib/features/videos/presentation/widgets/advanced_video_player.dart`

**Cuándo:** En el método `_onVideoEnded` cuando se completa un video

**Implementación:**
```dart
Future<void> _onVideoEnded() async {
  final soundService = GetIt.instance<SoundService>();
  final vibrationService = GetIt.instance<VibrationService>();
  
  await Future.wait([
    soundService.playClickSound(),
    vibrationService.lightImpact(),
  ]);
  
  // ... resto del código
}
```

---

## 🧭 4. NAVEGACIÓN Y UI GENERAL (Prioridad BAJA)

### Ubicaciones Clave:

#### 4.1. Botones de Navegación
**Archivo:** `lib/features/navigation/presentation/widgets/modern_bottom_navigation_bar.dart`

**Cuándo:** Al cambiar de pestaña

**Implementación:**
```dart
// En el onTap del BottomNavigationBar
onTap: (index) async {
  final soundService = GetIt.instance<SoundService>();
  final vibrationService = GetIt.instance<VibrationService>();
  
  await Future.wait([
    soundService.playClickSound(),
    vibrationService.selectionClick(),
  ]);
  
  // Cambiar de pestaña
}
```

#### 4.2. Botones de Acción General
**Archivo:** Varios archivos con botones importantes

**Estrategia:** Reemplazar `ElevatedButton` con `InteractiveButton` en:
- Botones de "Guardar"
- Botones de "Completar"
- Botones de "Siguiente"
- Botones de "Atrás" (opcional)

---

## 🎯 Priorización de Implementación

### Fase 1: Gamificación (Impacto Alto)
1. ✅ Ganancia de XP
2. ✅ Logro desbloqueado
3. ✅ Subida de nivel
4. ✅ Bonus de racha

### Fase 2: Lactación (Impacto Alto)
1. ✅ Registro rápido de lactación
2. ✅ Registro completo de lactación
3. ✅ Botón inteligente de lactación
4. ✅ Registro de peso
5. ✅ Registro de sueño

### Fase 3: Lecciones (Impacto Medio)
1. ✅ Completar lección
2. ✅ Completar video

### Fase 4: UI General (Impacto Bajo)
1. ✅ Botones de navegación
2. ✅ Botones de acción general

---

## 📝 Ejemplo de Integración Completa

### En GamificationBloc:

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final _soundService = GetIt.instance<SoundService>();
  final _vibrationService = GetIt.instance<VibrationService>();
  
  Future<void> _onAddXP(AddXP event, Emitter<GamificationState> emit) async {
    // ... lógica existente ...
    
    if (leveledUp) {
      // Feedback especial por subir de nivel
      await Future.wait([
        _soundService.playSuccessSound(),
        _vibrationService.heavyImpact(),
      ]);
    } else {
      // Feedback normal por ganar XP
      await Future.wait([
        _soundService.playClickSound(),
        _vibrationService.lightImpact(),
      ]);
    }
    
    // ... resto del código ...
  }
}
```

### En XPCelebrationAnimation:

```dart
import 'package:get_it/get_it.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';

class XPCelebrationAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Reproducir sonido y vibrar al mostrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soundService = GetIt.instance<SoundService>();
      final vibrationService = GetIt.instance<VibrationService>();
      
      Future.wait([
        soundService.playSuccessSound(),
        vibrationService.lightImpact(),
      ]);
    });
    
    // ... resto del código ...
  }
  
  static void show(BuildContext context, int xpAmount, {VoidCallback? onComplete}) {
    final soundService = GetIt.instance<SoundService>();
    final vibrationService = GetIt.instance<VibrationService>();
    
    // Feedback inmediato
    Future.wait([
      soundService.playSuccessSound(),
      vibrationService.lightImpact(),
    ]);
    
    // ... resto del código ...
  }
}
```

---

## ⚠️ Consideraciones Importantes

1. **No sobrecargar:** No agregar sonido/vibración en cada interacción pequeña
2. **Feedback diferenciado:** Usar diferentes intensidades según la importancia
3. **Respetar configuraciones:** Los servicios ya verifican si están habilitados
4. **Performance:** Usar `Future.wait()` para ejecutar sonido y vibración en paralelo
5. **Contexto:** Algunos eventos requieren contexto de UI, otros no

---

## 🚀 Plan de Acción Recomendado

1. **Empezar con Gamificación** (mayor impacto emocional)
2. **Luego Lactación** (acciones más frecuentes)
3. **Después Lecciones** (menos frecuente pero importante)
4. **Finalmente UI General** (polish final)

---

## 📦 Archivos a Modificar

### Gamificación:
- `lib/features/gamification/presentation/widgets/xp_celebration_animation.dart`
- `lib/features/gamification/presentation/widgets/achievement_unlocked_dialog.dart`
- `lib/features/gamification/presentation/bloc/gamification_bloc.dart`

### Lactación:
- `lib/features/lactation/presentation/widgets/quick_lactation_dialog.dart`
- `lib/features/lactation/presentation/pages/lactation_record_page.dart`
- `lib/features/lactation/presentation/pages/lactation_flow_page_enhanced.dart`
- `lib/features/lactation/presentation/widgets/smart_lactation_button.dart`
- `lib/features/lactation/presentation/pages/baby_weight_form_page.dart`
- `lib/features/lactation/presentation/pages/daily_sleep_form_page.dart`

### Lecciones:
- `lib/features/lessons/presentation/pages/lesson_videos_page.dart`
- `lib/features/videos/presentation/widgets/advanced_video_player.dart`

### Navegación:
- `lib/features/navigation/presentation/widgets/modern_bottom_navigation_bar.dart`

---

¿Quieres que implemente alguna de estas integraciones ahora?

