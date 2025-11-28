# Lista de Badges - Estado Actual y Mapeo de Achievements

## Badges Existentes (29 badges) ✅

### Badges Originales (3) - Usados como fallback genérico
1. `birrete.png` - Badge de graduación/estudios
2. `logro.png` - Badge genérico de logro
3. `medalla.png` - Badge de medalla

### Logros de Registros Totales (Milestones) - 6 badges ✅
4. `badge_10.png` - **Achievement:** `milestone_10` - "Primeros Pasos" (10 registros)
5. `badge_25.png` - **Achievement:** `milestone_25` - "Constante" (25 registros)
6. `badge_50.png` - **Achievement:** `milestone_50` - "Dedicada" (50 registros)
7. `badge_100.png` - **Achievement:** `milestone_100` - "Experta" (100 registros)
8. `badge_250.png` - **Achievement:** `milestone_250` - "Maestra" (250 registros)
9. `badge_500.png` - **Achievement:** `milestone_500` - "Leyenda" (500 registros)

### Logros de Registros Completos - 3 badges ✅
10. `badge_complete_25.png` - **Achievement:** `complete_25` - "Detallista" (25 registros completos)
11. `badge_complete_50.png` - **Achievement:** `complete_50` - "Completa" (50 registros completos)
12. `badge_complete_100.png` - **Achievement:** `complete_100` - "Perfeccionista" (100 registros completos)

### Logros de Racha - 4 badges ✅
13. `badge_streak_7.png` - **Achievement:** `streak_7` - "Comprometida" (7 días)
14. `badge_streak_30.png` - **Achievement:** `streak_30` - "Dedicada" (30 días)
15. `badge_streak_90.png` - **Achievement:** `streak_90` - "Trimestre Constante" (90 días)
16. `badge_streak_180.png` - **Achievement:** `streak_180` - "Semestre Legendario" (180 días)

### Logros de Niveles - 6 badges ✅
17. `badge_level_1.png` - **Achievement:** (disponible para `level_1` si se implementa)
18. `badge_level_3.png` - **Achievement:** `level_3` - "Nivel 3"
19. `badge_level_5.png` - **Achievement:** `level_5` - "Nivel 5"
20. `badge_level_10.png` - **Achievement:** `level_10` - "Nivel 10"
21. `badge_level_15.png` - **Achievement:** `level_15` - "Nivel 15"
22. `badge_level_20.png` - **Achievement:** `level_20` - "Nivel 20"

### Logros Especiales - 4 badges ✅
23. `badge_nocturnal_10.png` - **Achievement:** `nocturnal_10` - "Madrugadora" (10 registros entre 12am-6am)
24. `badge_weight_10.png` - **Achievement:** `weight_10` - "Crecimiento" (10 registros de peso)
25. `badge_sleep_20.png` - **Achievement:** `sleep_20` - "Sueño Dorado" (20 registros de sueño)
26. `badge_trivia_perfect_5.png` - **Achievement:** `trivia_perfect_5` - "Trivia Perfecta" (5 trivias con 100%)

### Logros de Tiempo (Días usando la app) - 4 badges ✅
27. `badge_first_week.png` - **Achievement:** `first_week` - "Primera Semana" (7 días usando la app)
28. `badge_first_month.png` - **Achievement:** `first_month` - "Primer Mes" (30 días usando la app)
29. `badge_three_months.png` - **Achievement:** `three_months` - "Tres Meses" (90 días usando la app)
30. `badge_six_months.png` - **Achievement:** `six_months` - "Seis Meses" (180 días usando la app)

## Badges Pendientes de Implementar (2 badges) 🔄

### Logros de Lecciones - 2 badges 🔄
1. `badge_lessons_7.png` - **Achievement:** `lessons_7` - "Estudiante Avanzada" (7 lecciones)
2. `badge_lessons_all.png` - **Achievement:** `lessons_all` - "Experta en Lactancia" (14 lecciones - todas)

## Resumen
- **Total de badges existentes:** 29 badges ✅
- **Total de badges pendientes de implementar:** 2 badges 🔄
- **Total de badges finales:** 31 badges (cuando se completen los pendientes)

## Nota sobre Logros No Implementados
Los siguientes achievements fueron considerados pero **no se implementarán**:
- `perfect_week` - "Semana Perfecta" (7 días consecutivos) - **NO se implementará**
- `perfect_month` - "Mes Perfecto" (30 días consecutivos) - **NO se implementará**

## Mapeo de Achievements a Badges

### Achievements con Badges Específicos (27 achievements)
Todos los achievements listados arriba tienen badges específicos asignados mediante la función `_getBadgeForAchievement()` en `achievement_service.dart`.

### Achievements con Emojis o Badges Genéricos
Los siguientes achievements usan emojis o badges genéricos rotativos:
- `lactation_1` a `lactation_5` - Usan badges genéricos rotativos
- `daily_3` a `daily_12` - Usan badges genéricos rotativos
- `first_lesson`, `student_5`, `learner_10`, `master_all` - Usan emojis (📚, 🎓)
- `streak_3` - Usa emoji (🔥)
- `nocturnal` - Usa emoji (🌙)
- `growth_tracker` - Usa emoji (📈)
- `complete_records_10`, `consistent_7_days` - Usan emojis

## Implementación Técnica
- **Función de mapeo:** `_getBadgeForAchievement(String achievementId)` en `achievement_service.dart`
- **Fallback:** Si un achievement no tiene badge específico, usa `_getRotatingBadge()` con los 3 badges genéricos
- **Ubicación de badges:** `assets/images/badges/`

## Nota
Los badges deben ser imágenes PNG con diseño consistente, apropiadas para el tema de lactancia materna y gamificación. Se recomienda usar colores suaves y temática relacionada con bebés, maternidad y logros.

