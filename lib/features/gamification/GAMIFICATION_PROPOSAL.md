# 🎮 Sistema de Gamificación - Propuesta Completa

## 📋 Resumen Ejecutivo

Sistema de gamificación estilo Duolingo pero básico para motivar:
- **Registros de lactancia** (rápido y completo)
- **Completar lecciones** (videos educativos)

---

## 🎯 Objetivos del Sistema

1. **Motivar el registro diario** de lactancia
2. **Incentivar el aprendizaje** completando lecciones
3. **Crear hábitos saludables** con rachas diarias
4. **Celebrar logros** con animaciones y recompensas
5. **Mantener el engagement** con progreso visible

---

## 🏗️ Arquitectura Propuesta

```
lib/features/gamification/
├── domain/
│   ├── entities/
│   │   ├── user_gamification_profile.dart    # Perfil de gamificación del usuario
│   │   ├── achievement.dart                  # Logros/Badges
│   │   ├── xp_transaction.dart               # Transacciones de XP
│   │   └── daily_streak.dart                 # Racha diaria
│   ├── repositories/
│   │   └── gamification_repository.dart      # Interface
│   └── services/
│       ├── xp_calculation_service.dart        # Cálculo de XP
│       ├── level_service.dart                 # Sistema de niveles
│       ├── achievement_service.dart            # Detección de logros
│       └── streak_service.dart                # Gestión de rachas
│
├── data/
│   ├── datasources/
│   │   ├── gamification_remote_data_source.dart
│   │   └── gamification_local_data_source.dart
│   ├── models/
│   │   └── user_gamification_profile_model.dart
│   └── repositories/
│       └── gamification_repository_impl.dart
│
└── presentation/
    ├── bloc/
    │   ├── gamification_bloc.dart
    │   ├── gamification_event.dart
    │   └── gamification_state.dart
    ├── widgets/
    │   ├── xp_bar_widget.dart                 # Barra de XP en HomePage
    │   ├── level_badge_widget.dart             # Badge de nivel
    │   ├── streak_widget.dart                 # Widget de racha
    │   ├── achievement_unlocked_dialog.dart   # Diálogo de logro desbloqueado
    │   ├── xp_celebration_animation.dart      # Animación de celebración XP
    │   ├── mascot_widget.dart                 # Muñequito animado
    │   └── achievements_list_widget.dart      # Lista de logros
    └── pages/
        └── gamification_profile_page.dart      # Página de perfil de gamificación
```

---

## 💎 Sistema de XP (Puntos de Experiencia)

### Fuentes de XP

| Acción | XP Base | Bonificaciones |
|--------|---------|----------------|
| **Registro rápido de lactancia** | 10 XP | +5 XP si es el primero del día |
| **Registro completo de lactancia** | 20 XP | +10 XP si incluye sueño |
| **Completar una lección** | 30 XP | +15 XP si es la primera del día |
| **Racha de 3 días** | 50 XP | Bonus único |
| **Racha de 7 días** | 100 XP | Bonus único |
| **Racha de 30 días** | 500 XP | Bonus único |
| **Registrar peso del bebé** | 15 XP | - |
| **Registrar sueño del bebé** | 10 XP | - |

### Fórmula de XP por Nivel

```
XP requerido para nivel N = 100 * N * (N + 1) / 2

Ejemplos:
- Nivel 1: 100 XP
- Nivel 2: 300 XP (100 + 200)
- Nivel 3: 600 XP (100 + 200 + 300)
- Nivel 5: 1,500 XP
- Nivel 10: 5,500 XP
```

---

## 📊 Sistema de Niveles

### Estructura de Niveles

- **Nivel 1-5**: Principiante (Bronce) 🥉
- **Nivel 6-10**: Intermedio (Plata) 🥈
- **Nivel 11-20**: Avanzado (Oro) 🥇
- **Nivel 21+**: Experto (Diamante) 💎

### Beneficios por Nivel

- **Cada nivel**: Desbloquea nuevos badges
- **Nivel 5, 10, 15, 20**: Desbloquea mascota especial
- **Nivel 10**: Desbloquea tema de app personalizado
- **Nivel 20**: Desbloquea título especial en perfil

---

## 🔥 Sistema de Racha (Streak)

### Funcionamiento

- **Racha diaria**: Registra al menos 1 lactancia o completa 1 lección
- **Se pierde**: Si no hay actividad por 1 día completo
- **Protección EMPÁTICA**: 
  - **3 "días de descanso" por semana** (no 1)
  - La mascota NUNCA se ve decepcionada o triste
  - Tono 100% de apoyo, nunca de culpa
  - **Modo Pausa**: La usuaria puede pausar la racha si sabe que tendrá una semana difícil
  - **Recuperación automática**: Si registra dentro de 48 horas, la racha continúa (no se pierde)

### Recompensas por Racha

| Días | Recompensa |
|------|------------|
| 3 días | 50 XP bonus |
| 7 días | 100 XP + Badge "Semana Perfecta" |
| 14 días | 200 XP + Badge "Dos Semanas" |
| 30 días | 500 XP + Badge "Mes Perfecto" |
| 60 días | 1,000 XP + Badge "Dos Meses" |
| 100 días | 2,000 XP + Badge "Centenario" |

---

## 🏆 Sistema de Logros (Achievements)

### Categorías de Logros

#### 1. **Registros de Lactancia**
- 🥛 **Primera Lactancia**: Registra tu primera lactancia
- 📝 **Registro Completo**: Completa 10 registros completos
- ⏰ **Puntual**: Registra lactancia dentro de 1 hora
- 📊 **Consistente**: 7 registros en 7 días
- 🎯 **Objetivo Diario**: 8+ registros en un día

#### 2. **Lecciones**
- 📚 **Primera Lección**: Completa tu primera lección
- 🎓 **Estudiante**: Completa 5 lecciones
- 🎓 **Aprendiz**: Completa 10 lecciones
- 🎓 **Maestro**: Completa todas las lecciones

#### 3. **Rachas**
- 🔥 **Iniciando**: Racha de 3 días
- 🔥 **Comprometida**: Racha de 7 días
- 🔥 **Dedicada**: Racha de 30 días
- 🔥 **Legendaria**: Racha de 100 días

#### 4. **Especiales**
- ⭐ **Nivel 5**: Alcanza nivel 5
- ⭐ **Nivel 10**: Alcanza nivel 10
- 💪 **Semana Perfecta**: 7 días consecutivos con actividad
- 🌙 **Nocturna**: Registra lactancia entre 12am-6am
- 📈 **Crecimiento**: Registra peso del bebé 5 veces

---

## 🎨 Mascota/Personaje (Muñequito)

### Concepto

Un **muñequito tierno** que:
- **Crece** según el nivel del usuario
- **Se anima** cuando gana XP
- **Celebra** cuando desbloquea logros
- **Motiva** cuando la racha está en riesgo
- **Duerme** cuando no hay actividad

### Estados del Muñequito

1. **Feliz** (default): Estado normal, sonriendo
2. **Celebrando**: Cuando gana XP (salta, aplaude)
3. **Pensativo**: Cuando está cerca de subir de nivel
4. **Preocupado** (EMPÁTICO): Cuando la racha está en riesgo - **NUNCA decepcionado o triste**
5. **Durmiendo**: Cuando no hay actividad hoy
6. **Especial**: Cuando desbloquea un logro importante
7. **Apoyando**: Cuando la usuaria usa "Modo Pausa" o "Día de Descanso" - muestra comprensión

### ⚠️ REGLA CRÍTICA: Tono Empático
- **NUNCA** usar lenguaje de culpa ("Perdiste tu racha")
- **SIEMPRE** usar lenguaje de apoyo ("Tómate un descanso, estaremos aquí cuando regreses")
- La mascota **NUNCA** debe verse triste o decepcionada
- Mensajes positivos incluso cuando se pierde la racha

### Implementación Técnica

```dart
// El muñequito puede ser:
// 1. Lottie animations (recomendado)
// 2. Sprite sheets con animaciones
// 3. SVG animado
// 4. Widgets Flutter animados

// Estados almacenados en:
// - user_gamification_profile.dart
// - mascot_state: 'happy', 'celebrating', 'thinking', etc.
```

### Diseño Sugerido

- **Estilo**: Tierno, minimalista, colores suaves
- **Tamaño**: 80x80px en HomePage, más grande en perfil
- **Animaciones**: 
  - Idle (respiración suave)
  - Celebración (salto + confetti)
  - Pensativo (mano en barbilla)
  - Preocupado (expresión triste)

---

## 🎬 Animaciones de Celebración

### Cuando se Gana XP

1. **Pop-up flotante**: "+20 XP" con animación de subida
2. **Barra de XP**: Se llena con animación suave
3. **Confetti**: Si sube de nivel
4. **Sonido opcional**: "ding" suave (configurable)

### Cuando se Desbloquea un Logro

1. **Diálogo modal**: Muestra el badge desbloqueado
2. **Animación del badge**: Escala + rotación
3. **Confetti**: Explosión de confetti
4. **Mascota**: Celebra junto al badge

### Cuando se Mantiene la Racha

1. **Notificación**: "¡Racha de 7 días! 🔥"
2. **Animación de fuego**: Efecto de llamas
3. **XP bonus**: Se muestra el bonus ganado

---

## 💾 Estructura de Datos

### UserGamificationProfile

```dart
class UserGamificationProfile {
  final String userId;
  final int totalXP;              // XP total acumulado
  final int currentLevel;         // Nivel actual
  final int currentLevelXP;       // XP en el nivel actual
  final int nextLevelXP;          // XP necesario para siguiente nivel
  final int currentStreak;        // Racha actual en días
  final DateTime? lastActivityDate; // Última fecha de actividad (CRÍTICO para offline)
  final DateTime? streakStartDate;  // Fecha de inicio de racha
  final List<String> unlockedAchievements; // IDs de logros desbloqueados
  final String mascotState;       // Estado actual del muñequito
  final int mascotLevel;          // Nivel del muñequito (crece con el usuario)
  final Map<String, int> dailyXP; // XP ganado por día (últimos 30 días)
  
  // NUEVOS CAMPOS EMPÁTICOS
  final int restDaysUsed;         // Días de descanso usados esta semana
  final int restDaysAvailable;    // Días de descanso disponibles (3 por semana)
  final bool isPauseModeActive;    // Modo pausa activo (no cuenta racha)
  final DateTime? pauseModeStartDate; // Cuándo empezó el modo pausa
  final DateTime? lastRestDayUsed; // Última vez que usó un día de descanso
  
  // OFFLINE-FIRST
  final bool isSynced;             // Si está sincronizado con Firestore
  final DateTime? lastSyncAt;      // Última sincronización
  
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Achievement

```dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;              // Emoji o asset path
  final AchievementType type;      // lactation, lesson, streak, special
  final int requiredValue;        // Valor requerido (ej: 7 días)
  final int xpReward;             // XP que otorga
  final bool isUnlocked;
  final DateTime? unlockedAt;
}
```

### XPTransaction

```dart
class XPTransaction {
  final String id;
  final String userId;
  final int amount;               // Cantidad de XP
  final XPSource source;          // lactation_record, lesson_completed, etc.
  final String? sourceId;         // ID del registro/lección
  final String? bonusReason;      // Razón del bonus (ej: "first_of_day")
  final DateTime timestamp;
}
```

---

## 🔌 Integración con la App

### 1. Al Guardar Registro de Lactancia

```dart
// En lactation_record_page.dart o lactation_flow_page_enhanced.dart
// Después de guardar exitosamente:

final gamificationBloc = context.read<GamificationBloc>();
gamificationBloc.add(
  AddXPFromLactationRecord(
    recordId: record.id,
    isCompleteRecord: record.tipoRegistro == 'completo',
    includesSleep: record.incluyeSueno,
  ),
);
```

### 2. Al Completar una Lección

```dart
// En lesson_videos_page.dart
// Cuando se marca como completada:

final gamificationBloc = context.read<GamificationBloc>();
gamificationBloc.add(
  AddXPFromLessonCompleted(
    lessonId: videoId,
    isFirstOfDay: _isFirstLessonToday(),
  ),
);
```

### 3. En HomePage

```dart
// Mostrar barra de XP y racha
GamificationBar(
  currentXP: gamificationState.currentLevelXP,
  nextLevelXP: gamificationState.nextLevelXP,
  level: gamificationState.currentLevel,
  streak: gamificationState.currentStreak,
)
```

---

## 📱 UI/UX Sugerida

### HomePage - Barra de Gamificación

```
┌─────────────────────────────────────────┐
│  🔥 Racha: 7 días    Nivel 5 🥉        │
│  ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░ 450/600 XP │
│  +20 XP (Registro completo)            │
└─────────────────────────────────────────┘
```

### Widget de Mascota

```
┌─────────────┐
│             │
│    😊       │  <- Muñequito feliz
│             │
│  Nivel 5    │
└─────────────┘
```

### Diálogo de Logro Desbloqueado

```
┌─────────────────────────────┐
│         🎉 ¡Felicidades!     │
│                             │
│         🏆                   │
│    Semana Perfecta          │
│                             │
│  Has mantenido una racha    │
│  de 7 días consecutivos     │
│                             │
│      +100 XP Bonus          │
│                             │
│      [¡Genial!]             │
└─────────────────────────────┘
```

---

## 🚀 Plan de Implementación

### Fase 1: Base (Semana 1)
1. ✅ Crear estructura de carpetas
2. ✅ Entidades básicas (UserGamificationProfile, Achievement)
3. ✅ Servicios básicos (XP Calculation, Level Service)
4. ✅ Data sources (local y remote)
5. ✅ BLoC básico

### Fase 2: Integración (Semana 2)
1. ✅ Integrar con registros de lactancia
2. ✅ Integrar con lecciones
3. ✅ Sistema de racha
4. ✅ Widgets básicos (XP bar, streak)

### Fase 3: Logros y Animaciones (Semana 3)
1. ✅ Sistema de logros
2. ✅ Animaciones de celebración
3. ✅ Diálogos de logros
4. ✅ Mascota básica

### Fase 4: Pulido (Semana 4)
1. ✅ Animaciones avanzadas
2. ✅ Mascota completa con estados
3. ✅ Página de perfil de gamificación
4. ✅ Testing y optimización

---

## 🎨 Recursos Necesarios

### Diseño
- [ ] Mascota en diferentes estados (Lottie o sprites)
- [ ] Iconos de badges/logros
- [ ] Animaciones de confetti
- [ ] Sonidos opcionales (ding, celebration)

### Assets
- `assets/animations/mascot_happy.json` (Lottie)
- `assets/animations/mascot_celebrating.json`
- `assets/animations/mascot_thinking.json`
- `assets/animations/confetti.json`
- `assets/icons/achievements/` (carpeta con badges)

---

## 📊 Métricas a Trackear

1. **XP ganado por día**
2. **Nivel promedio de usuarios**
3. **Racha promedio**
4. **Logros más desbloqueados**
5. **Tasa de retención diaria**

---

## 🔄 Sincronización Offline (CRÍTICO)

### Principios Offline-First

1. **TODO funciona offline primero**
   - XP se calcula y guarda localmente inmediatamente
   - Racha se actualiza localmente con timestamp
   - Logros se detectan localmente
   - Mascota funciona sin conexión

2. **Sincronización Inteligente**
   - Cuando hay conexión, sincroniza `XPTransaction` con timestamps
   - El backend reconstruye la racha basándose en las transacciones
   - Si hay conflicto, prioriza los datos locales (la usuaria tiene razón)

3. **Lógica de Racha Offline**
   - `lastActivityDate` se guarda en SQLite inmediatamente
   - Si la usuaria está offline 2 días y se conecta el día 3:
     - El backend analiza las `XPTransaction` con sus timestamps
     - Si hay actividad en días consecutivos (según timestamps), la racha continúa
     - No se rompe la racha por estar offline

4. **Estructura de Datos Offline**
   ```dart
   // SQLite: gamification_local.db
   - user_gamification_profile (caché local)
   - xp_transactions (cola de sincronización)
   - achievements (estado local)
   - streak_data (datos de racha con timestamps)
   ```

---

## 💡 Ideas Adicionales (Futuro)

1. **Desafíos semanales**: "Registra 20 lactancias esta semana"
2. **Ligas/Clasificaciones**: Comparar con otros usuarios (opcional, anónimo)
3. **Recompensas reales**: Descuentos en productos de lactancia (si hay patrocinadores)
4. **Compartir logros**: Compartir en redes sociales
5. **Estadísticas avanzadas**: Gráficas de progreso

---

## ✅ Checklist de Implementación

- [ ] Estructura de carpetas
- [ ] Entidades de dominio
- [ ] Servicios de cálculo
- [ ] Data sources
- [ ] BLoC
- [ ] Integración con lactancia
- [ ] Integración con lecciones
- [ ] Widgets UI
- [ ] Animaciones
- [ ] Mascota
- [ ] Testing
- [ ] Documentación

---

¿Listo para empezar? 🚀

