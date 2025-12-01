# 🍼 Implementación del Sistema de Etapas del Bebé con Rive

## 📋 Resumen Ejecutivo

Este documento describe la implementación de un sistema interactivo de etapas del bebé usando animaciones Rive, donde el bebé evoluciona según el progreso del usuario en las lecciones y su actividad de lactancia.

## 🎯 Objetivos

1. **3 Etapas del Bebé:**
   - `baby_born` (Recién nacido): idle, happy, worried
   - `baby_3months` (3 meses): idle, happy, worried  
   - `baby_6months` (6 meses): solo idle

2. **Estados Emocionales:**
   - `worried`: Sin registros de lactancia recientes
   - `happy`: Con registros activos o logros completados
   - `idle`: Estado por defecto/neutral

3. **Sistema de Desbloqueo:**
   - Basado en progreso de lecciones completadas
   - `baby_born`: 0-6 lecciones (por defecto)
   - `baby_3months`: 7-13 lecciones
   - `baby_6months`: 14+ lecciones (todas)

## 🏗️ Arquitectura Propuesta

### 1. Modificaciones al Modelo de Datos

#### `UserGamificationProfile` - Nuevo Campo

```dart
final String babyStage; // 'baby_born', 'baby_3months', 'baby_6months'
```

**Ubicación:** `lib/features/gamification/domain/entities/user_gamification_profile.dart`

**Valor por defecto:** `'baby_born'`

### 2. Nuevo Servicio: `BabyStageService`

**Ubicación:** `lib/features/gamification/domain/services/baby_stage_service.dart`

**Responsabilidades:**
- Calcular la etapa del bebé basada en lecciones completadas
- Determinar si debe actualizarse la etapa
- Integrar con `LeccionesProvider`

**Métodos principales:**
```dart
class BabyStageService {
  /// Calcula la etapa del bebé según lecciones completadas
  String calculateBabyStage(int completedLessons) {
    if (completedLessons >= 14) return 'baby_6months';
    if (completedLessons >= 7) return 'baby_3months';
    return 'baby_born';
  }
  
  /// Verifica si debe actualizarse la etapa
  bool shouldUpdateStage(String currentStage, int completedLessons) {
    final newStage = calculateBabyStage(completedLessons);
    return newStage != currentStage;
  }
}
```

### 3. Actualización de `GamificationService`

**Modificaciones necesarias:**

1. **Inyectar dependencias:**
   - `BabyStageService`
   - `LeccionesProvider` (o acceso a progreso de lecciones)

2. **Método para actualizar etapa del bebé:**
```dart
Future<Either<String, UserGamificationProfile>> updateBabyStage({
  required String userId,
  required int completedLessons,
}) async {
  // 1. Obtener perfil actual
  // 2. Calcular nueva etapa
  // 3. Actualizar perfil si cambió
  // 4. Guardar y retornar
}
```

3. **Integración con `addXPForQuickLactation`:**
   - Después de agregar XP, verificar si debe actualizarse la etapa
   - Llamar a `updateBabyStage` si es necesario

### 4. Actualización de `_determineMascotState`

**Lógica mejorada:**

```dart
String _determineMascotState(
  UserGamificationProfile profile,
  DailyStreak streak,
  int? lactationRecordsToday, // Nuevo parámetro
) {
  // 1. Verificar si hay registros de lactancia hoy
  if (lactationRecordsToday == null || lactationRecordsToday == 0) {
    // Sin registros recientes = worried
    return 'worried';
  }
  
  // 2. Verificar racha y logros
  if (profile.isPauseModeActive) return 'supporting';
  
  final streakStatus = _streakService.checkStreakStatus(streak);
  switch (streakStatus) {
    case StreakStatus.active:
      if (profile.levelProgress > 0.8) return 'thinking';
      return 'happy';
    case StreakStatus.atRisk:
      return 'worried';
    // ... resto de casos
  }
}
```

### 5. Actualización de Widgets Rive

#### `_BabyRiveAnimation` - Modificaciones

**Nuevos parámetros:**
```dart
class _BabyRiveAnimation extends StatefulWidget {
  final String state; // 'idle', 'happy', 'worried'
  final String babyStage; // 'baby_born', 'baby_3months', 'baby_6months'
  final double size;
}
```

**Cambios en `_onInit`:**
```dart
void _onInit(Artboard artboard) {
  // Usar el artboard según babyStage
  final artboardName = widget.babyStage; // 'baby_born', 'baby_3months', 'baby_6months'
  
  // Si es baby_6months, solo usar idle (no tiene happy/worried)
  if (artboardName == 'baby_6months') {
    // Forzar estado a idle
    _updateState('idle');
  } else {
    // Usar el estado normal
    _updateState(widget.state);
  }
}
```

**Cambios en `build`:**
```dart
@override
Widget build(BuildContext context) {
  return RiveWidgetBuilder(
    fileLoader: _fileLoader,
    artboardSelector: ArtboardSelector.byName(widget.babyStage), // Usar babyStage
    stateMachineSelector: StateMachineSelector.byName('State Machine 1'),
    onInit: _onInit,
    builder: (context, state) => switch (state) {
      // ... estados de carga
    },
  );
}
```

### 6. Integración con `LeccionesProvider`

**Opciones de implementación:**

**Opción A: Callback en `LeccionesProvider`**
```dart
// En LeccionesProvider
Function(int completedCount)? onLessonsCompletedChanged;

void marcarLeccionCompletada(int videoId) {
  _leccionesCompletadas.add(videoId);
  // ...
  onLessonsCompletedChanged?.call(_leccionesCompletadas.length);
  notifyListeners();
}
```

**Opción B: Observer Pattern**
- `GamificationService` escucha cambios en `LeccionesProvider`
- Actualiza automáticamente la etapa cuando cambia el conteo

**Opción C: Verificación Periódica**
- En `GamificationBloc`, verificar progreso de lecciones al cargar perfil
- Actualizar etapa si es necesario

**Recomendación:** Opción B (Observer Pattern) para reactividad automática.

### 7. Flujo de Actualización

```
1. Usuario completa una lección
   ↓
2. LeccionesProvider.marcarLeccionCompletada()
   ↓
3. Notifica a GamificationService (observer/callback)
   ↓
4. GamificationService.updateBabyStage()
   ↓
5. Calcula nueva etapa con BabyStageService
   ↓
6. Si cambió, actualiza UserGamificationProfile.babyStage
   ↓
7. Guarda en repositorio (local + Firestore)
   ↓
8. GamificationBloc emite nuevo estado
   ↓
9. Widgets se reconstruyen con nueva etapa
```

## 📝 Plan de Implementación

### Fase 1: Modelo de Datos
- [ ] Agregar campo `babyStage` a `UserGamificationProfile`
- [ ] Actualizar `copyWith` y `props`
- [ ] Actualizar serialización (local + Firestore)

### Fase 2: Servicios
- [ ] Crear `BabyStageService`
- [ ] Modificar `GamificationService` para integrar `BabyStageService`
- [ ] Agregar método `updateBabyStage`
- [ ] Integrar con `LeccionesProvider`

### Fase 3: Lógica de Estados
- [ ] Actualizar `_determineMascotState` para considerar registros de lactancia
- [ ] Agregar parámetro de conteo de registros diarios
- [ ] Integrar con `LactationService` para obtener conteo

### Fase 4: Widgets
- [ ] Actualizar `_BabyRiveAnimation` para usar `babyStage`
- [ ] Modificar `mascot_widget.dart`
- [ ] Modificar `companion_mascot_wrapper.dart`
- [ ] Manejar caso especial de `baby_6months` (solo idle)

### Fase 5: Integración
- [ ] Conectar `GamificationService` con `LeccionesProvider`
- [ ] Agregar listener en `GamificationBloc`
- [ ] Probar flujo completo de actualización

### Fase 6: Testing
- [ ] Probar desbloqueo de `baby_3months` (7 lecciones)
- [ ] Probar desbloqueo de `baby_6months` (14 lecciones)
- [ ] Probar estados emocionales (worried/happy/idle)
- [ ] Probar persistencia offline

## 🎨 Consideraciones de UX

### Animación de Transición
Cuando el bebé evoluciona de una etapa a otra:
- Mostrar animación de celebración
- Mensaje: "¡Tu bebé ha crecido! 🎉"
- Opcional: Efecto de confetti

### Feedback Visual
- Badge o indicador cuando está cerca de desbloquear siguiente etapa
- Progreso visual: "7/14 lecciones para desbloquear bebé de 3 meses"

### Mensajes Contextuales
- `baby_born` + `worried`: "Tu bebé necesita atención, registra una lactancia"
- `baby_3months` + `happy`: "¡Excelente! Tu bebé está creciendo bien"
- `baby_6months` + `idle`: "Tu bebé ha crecido mucho, sigue así"

## 🔄 Sincronización Offline

**Estrategia:**
1. Calcular etapa localmente basada en `LeccionesProvider` local
2. Al sincronizar con Firestore, verificar consistencia
3. Si hay discrepancia, usar la versión más avanzada

## 📊 Métricas a Considerar

- Tiempo promedio para desbloquear `baby_3months`
- Tiempo promedio para desbloquear `baby_6months`
- Frecuencia de estados `worried` vs `happy`
- Impacto en engagement del usuario

## 🚀 Próximos Pasos

1. Revisar y aprobar esta propuesta
2. Implementar Fase 1 (Modelo de Datos)
3. Implementar Fase 2 (Servicios)
4. Continuar con fases restantes
5. Testing exhaustivo
6. Deploy y monitoreo

## 📚 Referencias

- Archivo Rive: `assets/animations/baby_born.riv`
- Artboards disponibles: `baby_born`, `baby_3months`, `baby_6months`
- State Machine: `State Machine 1`
- Estados disponibles: `idle`, `happy`, `worried` (solo para baby_born y baby_3months)

