# Propuesta de Mejoras del Sistema de Gamificación

## 📊 1. Sistema de Niveles y XP

### Fórmula de Niveles
- **Fórmula actual**: XP total para nivel N = `100 * N * (N + 1) / 2`
- **XP por nivel**: `100 * (N + 1)` (XP necesario para pasar del nivel N al N+1)

### XP por Registros (Actual)
- **Registro rápido**: 10 XP (+5 si es primero del día)
- **Registro completo**: 20 XP (+5 si es primero del día, +10 si incluye sueño)
- **Peso del bebé**: 15 XP
- **Sueño del bebé**: 10 XP
- **Lección completada**: 30 XP (+15 si es primera del día)
- **Trivia completada**: 5 XP por pregunta correcta (+20 bonus si todas correctas)

### Bonuses de Milestones (Registros Totales)
- **10 registros**: +25 XP
- **25 registros**: +50 XP
- **50 registros**: +100 XP
- **100 registros**: +200 XP
- **250 registros**: +500 XP
- **500 registros**: +1000 XP

### Bonuses de Racha
- **3 días**: +50 XP
- **7 días**: +100 XP
- **30 días**: +500 XP
- **60 días**: +1000 XP
- **100 días**: +2000 XP

---

## 🏆 2. Logros Propuestos para 6 Meses

### Logros de Lactancia (Registros Totales)
**Badges necesarios: 6 imágenes adicionales**

1. **"Primeros Pasos"** (10 registros) - `badge_10.png` - 50 XP
2. **"Constante"** (25 registros) - `badge_25.png` - 100 XP
3. **"Dedicada"** (50 registros) - `badge_50.png` - 200 XP
4. **"Experta"** (100 registros) - `badge_100.png` - 400 XP
5. **"Maestra"** (250 registros) - `badge_250.png` - 800 XP
6. **"Leyenda"** (500 registros) - `badge_500.png` - 1500 XP

### Logros de Registros Completos
**Badges necesarios: 3 imágenes adicionales**

7. **"Detallista"** (25 registros completos) - `badge_complete_25.png` - 150 XP
8. **"Completa"** (50 registros completos) - `badge_complete_50.png` - 300 XP
9. **"Perfeccionista"** (100 registros completos) - `badge_complete_100.png` - 600 XP

### Logros de Lecciones
**Badges necesarios: 2 imágenes adicionales**

10. **"Estudiante Avanzada"** (7 lecciones) - `badge_lessons_7.png` - 200 XP
11. **"Experta en Lactancia"** (14 lecciones - todas) - `badge_lessons_all.png` - 1000 XP

### Logros de Racha
**Badges necesarios: 2 imágenes adicionales**

12. **"Semana de Fuego"** (7 días) - `badge_streak_7.png` - 100 XP
13. **"Mes Dedicado"** (30 días) - `badge_streak_30.png` - 500 XP
14. **"Trimestre Constante"** (90 días) - `badge_streak_90.png` - 1500 XP
15. **"Semestre Legendario"** (180 días) - `badge_streak_180.png` - 3000 XP

### Logros de Niveles
**Badges necesarios: 3 imágenes adicionales**

16. **"Nivel 3"** - `badge_level_3.png` - 100 XP
17. **"Nivel 5"** - `badge_level_5.png` - 200 XP
18. **"Nivel 10"** - `badge_level_10.png` - 500 XP
19. **"Nivel 15"** - `badge_level_15.png` - 1000 XP
20. **"Nivel 20"** - `badge_level_20.png` - 2000 XP

### Logros Especiales
**Badges necesarios: 4 imágenes adicionales**

21. **"Madrugadora"** (10 registros entre 12am-6am) - `badge_nocturnal_10.png` - 200 XP
22. **"Crecimiento"** (10 registros de peso) - `badge_weight_10.png` - 150 XP
23. **"Sueño Dorado"** (20 registros de sueño) - `badge_sleep_20.png` - 150 XP
24. **"Trivia Perfecta"** (5 trivias con 100%) - `badge_trivia_perfect_5.png` - 300 XP
25. **"Semana Perfecta"** (7 días consecutivos con actividad) - `badge_perfect_week.png` - 200 XP
26. **"Mes Perfecto"** (30 días consecutivos) - `badge_perfect_month.png` - 1000 XP

### Logros de Tiempo (Nuevos)
**Badges necesarios: 3 imágenes adicionales**

27. **"Primera Semana"** (7 días usando la app) - `badge_first_week.png` - 100 XP
28. **"Primer Mes"** (30 días usando la app) - `badge_first_month.png` - 300 XP
29. **"Tres Meses"** (90 días usando la app) - `badge_three_months.png` - 800 XP
30. **"Seis Meses"** (180 días usando la app) - `badge_six_months.png` - 2000 XP

**Total de badges necesarios: 23 imágenes nuevas**
**Total de logros propuestos: 30 logros adicionales (sumando a los existentes)**

---

## 🎨 3. Mejoras en la UI de Logros

### 3.1 Mostrar TODOS los Logros (Desbloqueados y Bloqueados)

**Cambio necesario en `companion_page.dart`:**

- Actualmente solo muestra logros desbloqueados
- **Nuevo**: Mostrar todos los logros, pero con diferentes estilos:
  - **Desbloqueados**: Color normal, brillante, con animación sutil
  - **Bloqueados**: Gris, con efecto de "bloqueo" (candado o overlay oscuro)

### 3.2 Diálogo Mejorado para Logros Bloqueados

Cuando el usuario toque un logro bloqueado, mostrar:
- Icono del logro (gris/bloqueado)
- Título del logro
- Descripción
- **"Objetivos para desbloquear"**: Lista clara de qué debe hacer
- Barra de progreso mostrando cuánto falta
- XP que recibirá al desbloquearlo

### 3.3 Cuadro Informativo "¿Cómo ganar XP?"

Agregar un botón/info card en la sección de logros que muestre:
- Registro rápido: 10 XP
- Registro completo: 20 XP
- Completar lección: 30 XP
- Completar trivia: 5 XP por pregunta
- Bonuses por racha, milestones, etc.

---

## 🔔 4. Sistema de Notificaciones de Logros

### 4.1 Indicador Rojo en Compañera

Cuando se desbloquea un logro:
- Mostrar un badge rojo con número en el ícono de "Compañera" en la navegación
- El número indica cuántos logros nuevos hay
- Al entrar a Compañera, mostrar animación del logro desbloqueado

### 4.2 Animación de Logro Desbloqueado

- Usar el widget existente `AchievementUnlockedDialog`
- Mostrar automáticamente cuando se detecta un logro nuevo
- Incluir sonido y vibración (ya implementado)

---

## 💡 5. Ideas para "Incentivos de Hoy"

### Opción 1: Sistema Rotativo (Recomendado)
- **Lunes**: "Inicio de Semana" - Bonus de +10 XP en el primer registro
- **Martes**: "Día de Aprendizaje" - Bonus de +15 XP al completar una lección
- **Miércoles**: "Día de Detalles" - Bonus de +10 XP en registros completos
- **Jueves**: "Día de Trivia" - Bonus de +5 XP extra en trivias
- **Viernes**: "Día de Crecimiento" - Bonus de +10 XP en registros de peso
- **Sábado**: "Día de Descanso" - No hay bonus, pero no cuenta como día perdido en racha
- **Domingo**: "Día de Reflexión" - Bonus de +20 XP al completar una lección

### Opción 2: Desafíos Diarios
- **Desafío del Día**: "Completa 5 registros hoy" → +50 XP bonus
- Cambia cada día
- Se muestra en la sección de "Incentivos de Hoy"

### Opción 3: Bonuses por Hora
- **Mañana (6am-12pm)**: +5 XP bonus en registros
- **Tarde (12pm-6pm)**: +5 XP bonus en lecciones
- **Noche (6pm-12am)**: +5 XP bonus en registros completos

### Opción 4: Combinación Mejorada (Recomendada) ✅ IMPLEMENTADA
- **Incentivo Base Diario**: Bonus pequeño (+5-10 XP) que cambia según el día de la semana
- **Desafío del Día Adaptativo**: Un desafío inteligente que se ajusta al estado del usuario
  - **Siempre disponibles**: Desafíos de registros (3, 5, 8 registros), registros completos, consistencia
  - **Condicionales**: Desafíos de trivias (solo si hay trivias pendientes), lecciones (solo si hay lecciones pendientes)
  - **Rotación por día**: El sistema prioriza diferentes tipos de desafíos según el día de la semana
  - **Recompensas**: +30 a +75 XP según la dificultad
- **Bonus por Hora**: Bonus pequeño adicional según la hora del día (opcional, futuro)

#### Características del Sistema Adaptativo:
1. **No depende de contenido limitado**: Los desafíos de registros siempre están disponibles
2. **Se adapta al progreso**: Si completaste todas las lecciones, no te muestra desafíos de lecciones
3. **Variedad garantizada**: Rotación por día de la semana para mantener interés
4. **Fallback inteligente**: Si no hay desafíos disponibles, siempre hay uno por defecto de registros
5. **Progreso visible**: Barra de progreso que muestra cuánto falta para completar el desafío

---

## 📋 Resumen de Implementación

### Prioridad Alta
1. ✅ Agregar logros adicionales (30 nuevos)
2. ✅ Mostrar logros bloqueados con estilo diferente
3. ✅ Mejorar diálogo de logros bloqueados con objetivos
4. ✅ Agregar cuadro informativo "¿Cómo ganar XP?"
5. ✅ Implementar notificación roja en Compañera
6. ✅ Sistema de incentivos diarios (Opción 4 recomendada)

### Prioridad Media
- Animaciones mejoradas para logros desbloqueados
- Estadísticas de progreso por tipo de logro

### Prioridad Baja
- Logros estacionales (Navidad, Día de la Madre, etc.)
- Logros sociales (compartir logros)

---

## 🎯 Badges Necesarios (23 imágenes)

### Por Categoría:
- **Registros Totales**: 6 badges (10, 25, 50, 100, 250, 500)
- **Registros Completos**: 3 badges (25, 50, 100)
- **Lecciones**: 2 badges (7, todas)
- **Racha**: 2 badges (7, 30, 90, 180) - reutilizar algunos
- **Niveles**: 3 badges (3, 5, 10, 15, 20) - reutilizar algunos
- **Especiales**: 4 badges (nocturna, peso, sueño, trivia)
- **Tiempo**: 3 badges (semana, mes, 3 meses, 6 meses)

**Nota**: Algunos badges pueden reutilizarse con diferentes colores o variaciones para optimizar recursos.

