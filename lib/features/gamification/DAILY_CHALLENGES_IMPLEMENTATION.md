# Implementación de Desafíos Diarios Adaptativos

## 🎯 Problema Resuelto

**Problema original**: Si el desafío del día es "completar una lección" pero el usuario ya completó todas las lecciones en una semana, ¿qué más puede hacer?

**Solución**: Sistema de desafíos diarios **adaptativo e inteligente** que:
1. ✅ **Siempre tiene desafíos disponibles** (no depende de contenido limitado)
2. ✅ **Se adapta al estado del usuario** (no muestra desafíos imposibles)
3. ✅ **Rota por día de la semana** (mantiene variedad)
4. ✅ **Tiene fallback garantizado** (siempre hay un desafío por defecto)

---

## 📋 Tipos de Desafíos

### 1. Desafíos de Registros (Siempre Disponibles) 🔄
- **3 Registros Hoy**: Completa 3 registros → +30 XP
- **5 Registros Hoy**: Completa 5 registros → +50 XP
- **Objetivo Diario**: Completa 8 registros → +75 XP
- **Inicio de Semana** (Lunes): Completa 4 registros → +40 XP
- **Fin de Semana** (Viernes): Completa 6 registros → +60 XP

### 2. Desafíos de Registros Completos (Siempre Disponibles) 🔄
- **Registros Detallados**: Completa 2 registros completos → +45 XP
- **Máximo Detalle**: Completa 3 registros completos → +70 XP

### 3. Desafíos de Trivias (Solo si hay Pendientes) 📚
- **Trivia del Día**: Completa una trivia → +50 XP
- **Avanzar en Trivias**: Completa una trivia nueva → +60 XP

### 4. Desafíos de Lecciones (Solo si hay Pendientes) 📖
- **Aprender Hoy**: Completa una lección nueva → +60 XP

### 5. Desafíos de Racha (Siempre Disponibles) 🔥
- **Racha de Semana**: Mantén racha por 7 días → +100 XP
- **Racha de Mes**: Mantén racha por 30 días → +500 XP

### 6. Desafíos de Consistencia (Siempre Disponibles) ⏰
- **Mañana Activa**: Completa 2 registros antes del mediodía → +35 XP
- **Noche Consistente**: Completa 2 registros después de las 6pm → +35 XP

---

## 🔄 Rotación por Día de la Semana

El sistema prioriza diferentes tipos de desafíos según el día:

| Día | Prioridad 1 | Prioridad 2 |
|-----|-------------|-------------|
| **Lunes** | Registros | Consistencia |
| **Martes** | Registros Completos | Trivias |
| **Miércoles** | Trivias | Estadísticas |
| **Jueves** | Registros Completos | Consistencia |
| **Viernes** | Registros | Racha |
| **Sábado** | Consistencia | Registros |
| **Domingo** | Estadísticas | Trivias |

---

## 🧠 Lógica de Selección

1. **Genera pool de desafíos disponibles** según:
   - Estado del usuario (lecciones/trivias completadas)
   - Registros de hoy
   - Racha actual

2. **Filtra desafíos imposibles**:
   - No muestra desafíos de lecciones si todas están completadas
   - No muestra desafíos de trivias si todas están completadas

3. **Selecciona el mejor desafío**:
   - Prioriza según el día de la semana
   - Si hay múltiples opciones, elige el de mayor recompensa XP
   - **Fallback garantizado**: Si no hay opciones, siempre hay un desafío por defecto de registros

---

## 💡 Ejemplos de Uso

### Usuario Nuevo (0 lecciones completadas)
- **Desafío del día**: "Aprender Hoy" (completar una lección) → +60 XP
- **Alternativas**: Desafíos de registros siempre disponibles

### Usuario Intermedio (7/14 lecciones)
- **Desafío del día**: "Aprender Hoy" (completar una lección) → +60 XP
- **Alternativas**: Desafíos de registros, trivias, consistencia

### Usuario Avanzado (14/14 lecciones completadas)
- **Desafío del día**: "Objetivo Diario" (8 registros) → +75 XP
- **Alternativas**: Desafíos de registros, registros completos, racha, consistencia
- **No muestra**: Desafíos de lecciones (ya completó todas)

### Usuario Experto (Todo completado)
- **Desafío del día**: "Objetivo Diario" (8 registros) → +75 XP
- **Alternativas**: Desafíos de registros, registros completos, racha, consistencia
- **Siempre tiene opciones**: Los desafíos de registros son infinitos y repetibles

---

## 📊 Progreso y Completado

Cada desafío muestra:
- **Barra de progreso**: 0% a 100%
- **Estado**: "En progreso" o "¡Completado!"
- **Recompensa XP**: Visible y destacada
- **Descripción clara**: Qué hacer para completarlo

---

## 🎨 Integración en UI

La sección "Incentivos de Hoy" mostrará:
1. **Desafío del Día** (principal, grande, destacado)
   - Icono del desafío
   - Título y descripción
   - Barra de progreso
   - Recompensa XP
   - Botón "Ver Detalles" (opcional)

2. **Badges Diarios** (secundario, debajo)
   - Los badges de registros diarios existentes
   - Se mantiene para compatibilidad

---

## ✅ Ventajas del Sistema

1. **Nunca se queda sin desafíos**: Siempre hay algo que hacer
2. **Adaptativo**: Se ajusta al progreso del usuario
3. **Variado**: Diferentes tipos de desafíos cada día
4. **Motivador**: Recompensas claras y alcanzables
5. **Justo**: No muestra desafíos imposibles
6. **Repetible**: Los desafíos de registros se pueden hacer todos los días

---

## 🔧 Próximos Pasos

1. ✅ Servicio creado (`daily_challenge_service.dart`)
2. ⏳ Integrar en `companion_page.dart`
3. ⏳ Obtener estadísticas necesarias (lecciones, trivias, etc.)
4. ⏳ Mostrar desafío del día con progreso
5. ⏳ Otorgar XP cuando se complete el desafío
6. ⏳ Guardar estado de completado (para no repetir el mismo día)

---

## 📝 Notas Técnicas

- El servicio es **stateless** (no guarda estado)
- El desafío se recalcula cada vez que se accede a la página
- El estado de completado se puede guardar en el perfil del usuario o en una tabla separada
- Los desafíos se pueden completar múltiples veces si son repetibles

