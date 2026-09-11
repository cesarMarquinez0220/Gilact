# 📖 Guía de Integración - Sistema de Gamificación

## 🎯 Resumen

Este documento explica cómo integrar el sistema de gamificación con las funcionalidades existentes de la app (lactancia, lecciones, etc.).

---

## 🔧 Configuración Inicial

### 1. Registrar en Dependency Injection

Agregar al archivo `lib/core/di/injection.dart`:

```dart
import 'package:get_it/get_it.dart';
import '../../features/gamification/data/datasources/gamification_local_data_source.dart';
import '../../features/gamification/data/datasources/gamification_remote_data_source.dart';
import '../../features/gamification/data/repositories/gamification_repository_impl.dart';
import '../../features/gamification/domain/repositories/gamification_repository.dart';
import '../../features/gamification/domain/services/gamification_service.dart';
import '../../core/services/connectivity_service.dart';

// En configureDependencies():
getIt.registerLazySingleton<GamificationLocalDataSource>(
  () => GamificationLocalDataSource(),
);

getIt.registerLazySingleton<GamificationRemoteDataSource>(
  () => GamificationRemoteDataSource(),
);

getIt.registerLazySingleton<GamificationRepository>(
  () => GamificationRepositoryImpl(
    localDataSource: getIt<GamificationLocalDataSource>(),
    remoteDataSource: getIt<GamificationRemoteDataSource>(),
    connectivityService: getIt<ConnectivityService>(),
  ),
);

getIt.registerLazySingleton<GamificationService>(
  () => GamificationService(
    repository: getIt<GamificationRepository>(),
  ),
);

getIt.registerLazySingleton<GamificationBloc>(
  () => GamificationBloc(
    repository: getIt<GamificationRepository>(),
  ),
);
```

### 2. Proporcionar BLoC en MaterialApp

En `main.dart` o donde tengas tu `MaterialApp`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'features/gamification/presentation/bloc/gamification_bloc.dart';

BlocProvider<GamificationBloc>(
  create: (context) => GetIt.instance<GamificationBloc>()
    ..add(LoadGamificationProfile(userId)),
  child: MaterialApp(...),
)
```

---

## 📝 Integración con Registros de Lactancia

### En `LactationService` o donde guardes registros:

```dart
import 'package:get_it/get_it.dart';
import '../../features/gamification/domain/services/gamification_service.dart';

// Después de guardar un registro rápido:
final gamificationService = GetIt.instance<GamificationService>();
final result = await gamificationService.addXPForQuickLactation(
  userId: userId,
  recordId: record.id,
  timestamp: DateTime.now(),
  isFirstOfDay: _isFirstRecordToday(),
);

result.fold(
  (error) => print('Error agregando XP: $error'),
  (profile) {
    // Opcional: Mostrar animación de celebración
    XPCelebrationAnimation.show(context, transaction.amount);
  },
);

// Después de guardar un registro completo:
final result = await gamificationService.addXPForCompleteLactation(
  userId: userId,
  recordId: record.id,
  timestamp: DateTime.now(),
  includesSleep: record.incluyeSueno,
  isFirstOfDay: _isFirstRecordToday(),
);
```

### En `LactationRecordPage` o `LactationFlowPage`:

```dart
// Después de guardar exitosamente:
final gamificationService = GetIt.instance<GamificationService>();

// Agregar XP
await gamificationService.addXPForCompleteLactation(
  userId: userId,
  recordId: savedRecord.id,
  timestamp: DateTime.now(),
  includesSleep: record.incluyeSueno,
  isFirstOfDay: _isFirstRecordToday(),
);

// Detectar logros
final achievements = await gamificationService.detectAndUnlockAchievements(
  userId: userId,
  totalLactationRecords: totalRecords,
  completeLactationRecords: completeRecords,
  totalLessonsCompleted: lessonsCompleted,
  babyWeightRecords: weightRecords,
  hasNocturnalRecord: _hasNocturnalRecord(),
  dailyRecordsToday: _dailyRecordsCount(),
);

// Mostrar diálogo si hay logros nuevos
if (achievements.isRight() && achievements.getOrElse(() => []).isNotEmpty) {
  for (final achievement in achievements.getOrElse(() => [])) {
    AchievementUnlockedDialog.show(
      context,
      achievement,
      achievement.xpReward,
    );
  }
}
```

---

## 📚 Integración con Lecciones

### En el provider o servicio de lecciones:

```dart
import 'package:get_it/get_it.dart';
import '../../features/gamification/domain/services/gamification_service.dart';

// Después de completar una lección:
final gamificationService = GetIt.instance<GamificationService>();
final result = await gamificationService.addXPForLessonCompleted(
  userId: userId,
  lessonId: lesson.id,
  timestamp: DateTime.now(),
  isFirstOfDay: _isFirstLessonToday(),
);

result.fold(
  (error) => print('Error agregando XP: $error'),
  (profile) {
    // Mostrar animación
    XPCelebrationAnimation.show(context, 30); // 30 XP por lección
  },
);
```

---

## ⚖️ Integración con Registro de Peso

### En `BabyWeightFormPage`:

```dart
// Después de guardar el peso:
final gamificationService = GetIt.instance<GamificationService>();
await gamificationService.addXPForBabyWeight(
  userId: userId,
  recordId: savedRecord.id,
  timestamp: DateTime.now(),
);
```

---

## 😴 Integración con Registro de Sueño

### En `DailySleepFormPage`:

```dart
// Después de guardar el sueño:
final gamificationService = GetIt.instance<GamificationService>();
await gamificationService.addXPForBabySleep(
  userId: userId,
  recordId: savedRecord.id,
  timestamp: DateTime.now(),
);
```

---

## 🏠 Mostrar Widgets en HomePage

### Agregar widgets de gamificación:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/gamification/presentation/bloc/gamification_bloc.dart';
import '../../features/gamification/presentation/bloc/gamification_state.dart';
import '../../features/gamification/presentation/widgets/xp_bar_widget.dart';
import '../../features/gamification/presentation/widgets/streak_widget.dart';
import '../../features/gamification/presentation/widgets/mascot_widget.dart';

// En el build de HomePage:
BlocBuilder<GamificationBloc, GamificationState>(
  builder: (context, state) {
    if (state is GamificationLoaded) {
      return Column(
        children: [
          // Mascota
          MascotWidget(profile: state.profile),
          
          // Barra de XP
          XPBarWidget(profile: state.profile),
          
          // Racha
          FutureBuilder<DailyStreak?>(
            future: _getStreak(state.profile.userId),
            builder: (context, snapshot) {
              return StreakWidget(
                profile: state.profile,
                streak: snapshot.data,
              );
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  },
)
```

---

## 🔄 Sincronización Automática

### En `HomePage` o cuando se restaura la conexión:

```dart
// Cuando se restaura la conexión:
BlocProvider.of<GamificationBloc>(context).add(
  SyncWithFirestore(userId),
);
```

---

## 🎨 Mostrar Animaciones

### Cuando se gana XP:

```dart
import '../../features/gamification/presentation/widgets/xp_celebration_animation.dart';

// Después de agregar XP:
XPCelebrationAnimation.show(context, xpAmount);
```

### Cuando se desbloquea un logro:

```dart
import '../../features/gamification/presentation/widgets/achievement_unlocked_dialog.dart';

// Después de detectar logros:
if (newAchievements.isNotEmpty) {
  for (final achievement in newAchievements) {
    AchievementUnlockedDialog.show(
      context,
      achievement,
      achievement.xpReward,
    );
  }
}
```

---

## 📊 Verificar si es el Primer Registro/Lección del Día

### Helper function:

```dart
bool _isFirstRecordToday(String userId) async {
  final repository = GetIt.instance<GamificationRepository>();
  final transactions = await repository.getXPTransactions(userId);
  
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  
  return transactions.fold(
    (_) => true,
    (list) {
      final todayTransactions = list.where((t) {
        return t.timestamp.isAfter(todayStart) &&
               (t.source == XPSource.lactationRecordQuick ||
                t.source == XPSource.lactationRecordComplete);
      }).toList();
      
      return todayTransactions.isEmpty;
    },
  );
}
```

---

## ⚠️ Consideraciones Importantes

1. **Offline-First**: Todo se guarda localmente primero, luego se sincroniza cuando hay conexión.

2. **No bloquear UI**: Las operaciones de gamificación no deben bloquear la UI. Usar `async/await` sin `await` si no necesitas el resultado inmediatamente.

3. **Manejo de Errores**: Siempre usar `fold` para manejar `Either` y no mostrar errores críticos al usuario si falla la gamificación.

4. **Performance**: No llamar `detectAndUnlockAchievements` en cada registro. Hacerlo periódicamente o después de acciones importantes.

---

## 🧪 Testing

Para probar la integración:

1. Registrar una lactancia rápida → Debe agregar 10 XP
2. Registrar una lactancia completa → Debe agregar 20 XP
3. Completar una lección → Debe agregar 30 XP
4. Registrar 3 días consecutivos → Debe desbloquear logro de racha
5. Verificar que los widgets se muestran correctamente en HomePage

---

## 📝 Próximos Pasos

1. Integrar con `LactationService`
2. Integrar con `LeccionesProvider`
3. Agregar widgets a `HomePage`
4. Configurar sincronización automática
5. Probar en dispositivo real

