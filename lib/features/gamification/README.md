# 🎮 Sistema de Gamificación - GuiLact

Sistema completo de gamificación estilo Duolingo para motivar el registro de lactancia y el aprendizaje.

## ✅ Implementación Completada

### 📦 Estructura
- ✅ **Domain Layer**: Entidades, servicios y repositorios
- ✅ **Data Layer**: Data sources local (SQLite) y remoto (Firestore)
- ✅ **Presentation Layer**: BLoC, widgets y animaciones

### 🎯 Características

1. **Sistema de XP**
   - Registro rápido: 10 XP
   - Registro completo: 20 XP (+10 si incluye sueño)
   - Lección completada: 30 XP
   - Registro de peso: 15 XP
   - Registro de sueño: 10 XP
   - Bonuses por primera acción del día

2. **Sistema de Niveles**
   - Fórmula: `100 * N * (N + 1) / 2`
   - Rangos: Bronce, Plata, Oro, Diamante
   - Progreso visual con barra de XP

3. **Sistema de Racha (Empático)**
   - 3 días de descanso por semana
   - Recuperación automática (48 horas)
   - Modo pausa
   - Mensajes empáticos (nunca culpa)

4. **Sistema de Logros**
   - 18 logros diferentes
   - Categorías: Lactancia, Lecciones, Racha, Especiales
   - Detección automática

5. **Mascota Animada**
   - Estados: happy, celebrating, thinking, worried, supporting, sleeping
   - Usa Lottie animation (Happy Dog.json)
   - Mensajes empáticos según estado

### 🛡️ Características Empáticas

- ✅ 3 días de descanso por semana (no 1)
- ✅ Recuperación automática de racha
- ✅ Modo pausa
- ✅ Mensajes siempre positivos
- ✅ Mascota nunca triste o decepcionada

### 📱 Offline-First

- ✅ Todo se guarda localmente primero (SQLite)
- ✅ Sincronización inteligente con Firestore
- ✅ Reconstrucción de racha desde transacciones
- ✅ No se pierde racha por estar offline

## 📁 Archivos Principales

### Domain
- `entities/`: UserGamificationProfile, Achievement, XPTransaction, DailyStreak
- `services/`: XPCalculationService, LevelService, StreakService, AchievementService, GamificationService
- `repositories/`: GamificationRepository (interface)

### Data
- `datasources/`: GamificationLocalDataSource, GamificationRemoteDataSource
- `repositories/`: GamificationRepositoryImpl

### Presentation
- `bloc/`: GamificationBloc, Events, States
- `widgets/`: XPBarWidget, StreakWidget, MascotWidget, AchievementUnlockedDialog, XPCelebrationAnimation

## 🚀 Uso Rápido

### 1. Agregar XP por Registro de Lactancia

```dart
final gamificationService = GetIt.instance<GamificationService>();
await gamificationService.addXPForQuickLactation(
  userId: userId,
  recordId: record.id,
  timestamp: DateTime.now(),
  isFirstOfDay: true,
);
```

### 2. Mostrar Widgets en HomePage

```dart
BlocBuilder<GamificationBloc, GamificationState>(
  builder: (context, state) {
    if (state is GamificationLoaded) {
      return Column(
        children: [
          MascotWidget(profile: state.profile),
          XPBarWidget(profile: state.profile),
          StreakWidget(profile: state.profile),
        ],
      );
    }
    return const SizedBox.shrink();
  },
)
```

### 3. Mostrar Animación de Celebración

```dart
XPCelebrationAnimation.show(context, xpAmount);
```

## 📚 Documentación

- `GAMIFICATION_PROPOSAL.md`: Propuesta completa del sistema
- `CRITICAL_CONSIDERATIONS.md`: Consideraciones empáticas
- `INTEGRATION_GUIDE.md`: Guía de integración paso a paso
- `IMPLEMENTATION_STATUS.md`: Estado de implementación

## 🎨 Assets Necesarios

- ✅ `assets/animations/Happy Dog.json` (Lottie)
- ✅ `assets/images/badges/birrete.png`
- ✅ `assets/images/badges/logro.png`
- ✅ `assets/images/badges/medalla.png`
- ✅ `assets/images/badges/racha.png`

## ⚙️ Configuración

1. Agregar assets al `pubspec.yaml` (✅ ya agregado)
2. Registrar en Dependency Injection (ver `INTEGRATION_GUIDE.md`)
3. Proporcionar BLoC en MaterialApp
4. Integrar con LactationService y LeccionesProvider

## 🧪 Testing

Para probar:
1. Registrar lactancia → Verificar XP
2. Completar lección → Verificar XP
3. 3 días consecutivos → Verificar logro de racha
4. Verificar widgets en HomePage
5. Probar offline → Verificar que funciona

## 📊 Próximos Pasos

1. Integrar con `LactationService`
2. Integrar con `LeccionesProvider`
3. Agregar widgets a `HomePage`
4. Configurar sincronización automática
5. Ajustar valores de XP basándose en datos reales (Beta)

---

**Nota**: Este sistema está diseñado con un enfoque empático y offline-first, priorizando el bienestar de las usuarias sobre la gamificación agresiva.

