# 📋 Consideraciones Adicionales para Perfil Preparto

## ✅ Ya Implementado

1. **Animación Rive del Bebé**: Ocultada para preparto ✓
2. **Desafíos Diarios**: Solo lecciones y trivias para preparto ✓
3. **Notificaciones**: Solo se programan para postparto ✓
4. **Trivias**: Repetibles para preparto (ganan XP cada vez) ✓
5. **Health Page**: Cards de peso y sueño ocultos para preparto ✓
6. **Countdown**: Visible en Home para preparto ✓
7. **Botón Actualizar a Postparto**: Aparece cuando faltan 4-5 días ✓

---

## 🔍 Consideraciones Adicionales Necesarias

### 1. **Baby Stage (Etapa del Bebé)**

**Problema**: El `BabyStageService` calcula la etapa basada en lecciones completadas, pero para preparto no tiene sentido tener un "bebé" que crece.

**Solución Propuesta**:
- Para usuarios preparto, siempre mantener `babyStage = 'baby_born'` o usar un valor especial como `'prepartum'`
- No mostrar el diálogo de "Baby Stage Upgrade" para preparto
- El cálculo de etapa solo debe aplicarse cuando el usuario es postparto

**Archivos a modificar**:
- `lib/features/gamification/domain/services/baby_stage_service.dart`
- `lib/features/lessons/presentation/providers/lecciones_provider.dart` (donde se actualiza la etapa)
- `lib/features/lessons/presentation/pages/lesson_videos_page.dart` (donde se muestra el diálogo)

---

### 2. **Logros (Achievements) Relacionados con Postparto**

**Problema**: Muchos logros están relacionados con registros de lactancia, peso del bebé, sueño, que no aplican a preparto.

**Logros que NO deberían desbloquearse para preparto**:
- `daily_3`, `daily_5`, `daily_10` (registros diarios de lactancia)
- `milestone_10`, `milestone_25`, `milestone_50`, etc. (milestones de lactancia)
- `complete_25`, `complete_50`, `complete_100` (registros completos)
- `nocturnal_10` (registros nocturnos)
- `weight_10` (registros de peso)
- `sleep_20` (registros de sueño)

**Logros que SÍ deberían estar disponibles para preparto**:
- `lessons_7`, `lessons_all` (lecciones completadas)
- `trivia_perfect_5` (trivias perfectas)
- `streak_7`, `streak_30`, `streak_90`, `streak_180` (rachas)
- `level_1`, `level_3`, `level_5`, etc. (niveles)
- `first_week`, `first_month`, `three_months`, `six_months` (días usando la app)

**Solución Propuesta**:
- Modificar `AchievementService.detectNewAchievements()` para recibir `isPrePartum`
- Filtrar logros relacionados con lactancia/peso/sueño si es preparto
- O mejor: crear un método `getAvailableAchievementsForPrepartum()` que retorne solo los logros relevantes

**Archivos a modificar**:
- `lib/features/gamification/domain/services/achievement_service.dart`
- `lib/features/gamification/domain/services/gamification_service.dart`

---

### 3. **Estado de la Mascota (mascotState)**

**Problema**: `_determineMascotState()` verifica registros de lactancia para determinar si el bebé está "worried". Para preparto, esto no aplica.

**Solución Propuesta**:
- Para preparto, el estado debería basarse solo en:
  - Racha activa → `'happy'`
  - Racha en riesgo → `'worried'`
  - Sin actividad → `'sleeping'`
  - Cerca de subir nivel → `'thinking'`
  - Modo pausa → `'supporting'`
- No considerar registros de lactancia para preparto

**Archivos a modificar**:
- `lib/features/gamification/presentation/bloc/gamification_bloc.dart` (`_determineMascotState`)

---

### 4. **Validaciones en Formularios de Registro**

**Estado Actual**: Ya hay validaciones en algunos lugares:
- `lactation_record_dialog.dart` ✓
- `lactation_flow_service.dart` ✓
- `lactation_calendar_widget.dart` ✓

**Verificar**:
- `daily_sleep_form_page.dart` - ¿Tiene validación para preparto?
- Botones de acceso rápido a registro de lactancia en Home
- Navegación desde notificaciones (aunque ya no se programan para preparto)

---

### 5. **Estadísticas y Dashboard**

**Problema**: Las estadísticas de lactancia, peso, sueño no deberían mostrarse para preparto.

**Verificar**:
- `CompanionStatsSummary` - ¿Muestra estadísticas de lactancia?
- Dashboard de Home para postparto vs preparto
- Gráficos y visualizaciones de datos

**Archivos a revisar**:
- `lib/features/navigation/presentation/widgets/companion_stats_summary.dart`
- `lib/features/navigation/presentation/pages/home_page.dart`

---

### 6. **Racha (Streak)**

**Estado Actual**: La racha se actualiza con cualquier actividad que otorgue XP. Para preparto, solo pueden ganar XP con:
- Completar lecciones
- Completar trivias

**Consideración**: Esto está bien, pero deberíamos verificar que:
- La racha se actualiza correctamente cuando completan lecciones/trivias
- Los mensajes de racha son apropiados para preparto (no mencionan "registros de lactancia")

**Archivos a revisar**:
- `lib/features/gamification/domain/services/streak_service.dart`
- Mensajes relacionados con racha en traducciones

---

### 7. **Navegación y Accesos**

**Verificar que estén ocultos/deshabilitados para preparto**:
- Botón de registro rápido de lactancia en Home
- Acceso a calendario de lactancia
- Acceso a registro de peso del bebé
- Acceso a registro de sueño
- Navegación desde widgets/cards relacionados con postparto

**Archivos a revisar**:
- `lib/features/navigation/presentation/pages/home_page.dart`
- `lib/features/navigation/presentation/widgets/postparto_profile_widget.dart`
- Todos los widgets de navegación rápida

---

### 8. **Mensajes y Textos**

**Consideración**: Todos los mensajes, tooltips, y textos deberían ser apropiados para preparto:
- No mencionar "tu bebé" si es preparto
- Usar lenguaje como "cuando llegue tu bebé" o "preparándote para tu bebé"
- Mensajes motivacionales enfocados en preparación y aprendizaje

**Archivos a revisar**:
- `assets/translations/es.json`
- `assets/translations/en.json`
- Mensajes en widgets de gamificación

---

### 9. **Inicialización del Perfil de Gamificación**

**Consideración**: Cuando se crea un perfil de gamificación para un usuario preparto:
- `babyStage` debería ser `'baby_born'` o `'prepartum'`
- `mascotState` debería ser `'idle'` o `'happy'`
- No debería intentar calcular etapa basada en lecciones hasta que sea postparto

**Archivos a revisar**:
- `lib/features/gamification/data/datasources/gamification_remote_data_source.dart`
- `lib/features/gamification/domain/services/gamification_service.dart`

---

### 10. **Transición de Preparto a Postparto**

**Consideración**: Cuando un usuario actualiza de preparto a postparto:
- ¿Se debe recalcular la etapa del bebé basada en lecciones completadas?
- ¿Se deben activar notificaciones automáticamente?
- ¿Se debe mostrar el formulario de registro del bebé?
- ¿Se deben migrar datos de gamificación?

**Ya implementado**:
- Botón de actualización ✓
- Pantalla de felicitaciones ✓
- Navegación a formulario de postparto ✓

**Verificar**:
- Recalcular etapa del bebé al actualizar
- Activar notificaciones automáticamente
- Migrar/actualizar perfil de gamificación

---

## 📝 Resumen de Acciones Prioritarias

1. **Alta Prioridad**:
   - [ ] Filtrar logros relacionados con lactancia/peso/sueño para preparto
   - [ ] Ajustar `_determineMascotState()` para no considerar lactancia en preparto
   - [ ] Mantener `babyStage` fijo para preparto (no calcular basado en lecciones)

2. **Media Prioridad**:
   - [ ] Verificar y ocultar accesos a formularios de lactancia/peso/sueño
   - [ ] Revisar estadísticas mostradas en Companion page
   - [ ] Ajustar mensajes y textos para preparto

3. **Baja Prioridad**:
   - [ ] Revisar inicialización del perfil de gamificación
   - [ ] Mejorar transición de preparto a postparto
   - [ ] Revisar todos los mensajes y tooltips

