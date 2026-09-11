# ⚠️ Consideraciones Críticas - Sistema de Gamificación

## 🎯 Principios Fundamentales

### 1. EMPATÍA PRIMERO
Esta app trata con madres primerizas, a menudo cansadas, estresadas y vulnerables. 
**NUNCA** debemos crear ansiedad adicional.

### 2. OFFLINE-FIRST
Una madre registrando a las 3 AM puede no tener Wi-Fi. 
**TODO** debe funcionar offline primero.

### 3. TONO POSITIVO
**NUNCA** usar lenguaje de culpa. **SIEMPRE** lenguaje de apoyo.

---

## 🛡️ Protecciones Implementadas

### Sistema de Racha Empático

✅ **3 días de descanso por semana** (no 1)
✅ **Recuperación automática**: Si registra dentro de 48 horas, la racha continúa
✅ **Modo Pausa**: La usuaria puede pausar la racha si sabe que tendrá una semana difícil
✅ **Mascota nunca decepcionada**: Solo estados empáticos (preocupado, pensativo, apoyando)

### Mensajes Empáticos

❌ **NUNCA**: "Perdiste tu racha"
✅ **SIEMPRE**: "Tómate un descanso, estaremos aquí cuando regreses"

❌ **NUNCA**: "No registraste hoy"
✅ **SIEMPRE**: "¿Necesitas un día de descanso? Puedes usarlo sin perder tu progreso"

### Estados de Mascota

- ✅ **Feliz**: Estado normal
- ✅ **Celebrando**: Cuando gana XP
- ✅ **Pensativo**: Cerca de subir nivel
- ✅ **Preocupado**: Racha en riesgo (pero empático, no triste)
- ✅ **Apoyando**: Cuando usa modo pausa o día de descanso
- ❌ **NUNCA**: Triste, decepcionada, enojada

---

## 📱 Sincronización Offline-First

### Principios

1. **Todo se guarda localmente primero**
   - XP se calcula y guarda en SQLite inmediatamente
   - Racha se actualiza localmente con timestamp preciso
   - Logros se detectan localmente

2. **Sincronización inteligente**
   - Cuando hay conexión, sincroniza `XPTransaction` con timestamps
   - El backend reconstruye la racha basándose en las transacciones
   - Si hay conflicto, **prioriza datos locales** (la usuaria tiene razón)

3. **Lógica de racha offline**
   - `lastActivityDate` se guarda en SQLite con timestamp preciso
   - Si la usuaria está offline 2 días y se conecta el día 3:
     - El backend analiza las `XPTransaction` con sus timestamps
     - Si hay actividad en días consecutivos (según timestamps), la racha continúa
     - **NO se rompe la racha por estar offline**

### Estructura de Datos Offline

```dart
// SQLite: gamification_local.db
- user_gamification_profile (caché local)
- xp_transactions (cola de sincronización con timestamps)
- achievements (estado local)
- streak_data (datos de racha con timestamps precisos)
```

---

## ⚖️ Balance de XP (Ajustable)

### Valores Iniciales (Beta)

| Acción | XP Base | Notas |
|--------|---------|-------|
| Registro rápido | 10 XP | Acción principal - puede necesitar aumento |
| Registro completo | 20 XP | +10 si incluye sueño |
| Lección completada | 30 XP | +15 si es primera del día |
| Registro de peso | 15 XP | - |
| Registro de sueño | 10 XP | - |

### Sistema de Análisis

El `XPTransaction` permite:
- Analizar de dónde proviene la mayoría del XP
- Ajustar valores para incentivar lo que realmente ayuda
- Detectar si las usuarias "fingen" completar lecciones solo por XP

**Plan**: En Fase 4 o Beta, ajustar valores basándose en datos reales.

---

## 🎨 Implementación de Mascota

### Estados y Mensajes

| Estado | Cuándo | Mensaje | Tono |
|--------|--------|---------|------|
| Feliz | Default | "¡Hola! ¿Cómo estás hoy?" | Amigable |
| Celebrando | Gana XP | "¡Excelente trabajo! 🎉" | Entusiasta |
| Pensativo | Cerca de subir nivel | "Estás muy cerca de subir de nivel" | Motivador |
| Preocupado | Racha en riesgo | "Tu racha está en riesgo, pero puedes usar un día de descanso" | Empático, no culposo |
| Apoyando | Modo pausa activo | "Tómate el tiempo que necesites, estaremos aquí" | Comprensivo |
| Durmiendo | Sin actividad hoy | "Descansa bien, te esperamos mañana" | Cálido |

### Implementación Técnica

**Recomendado**: Lottie animations
- `mascot_happy.json`
- `mascot_celebrating.json`
- `mascot_thinking.json`
- `mascot_supporting.json`
- `mascot_sleeping.json`

**NUNCA crear**: `mascot_sad.json` o `mascot_disappointed.json`

---

## 📊 Métricas a Monitorear

1. **Tasa de uso de días de descanso**: Si es muy alta, aumentar disponibilidad
2. **Tasa de pérdida de racha**: Si es muy alta, hacer el sistema más flexible
3. **XP por fuente**: Ajustar valores si hay desbalance
4. **Engagement**: Si la gamificación aumenta o disminuye el uso de la app

---

## ✅ Checklist de Implementación Empática

- [x] 3 días de descanso por semana (no 1)
- [x] Modo pausa implementado
- [x] Recuperación automática de racha (48 horas)
- [x] Mascota nunca decepcionada
- [x] Mensajes siempre positivos
- [x] Offline-first en toda la lógica
- [x] Timestamps precisos para sincronización
- [x] Sistema de análisis de XP preparado

---

## 🚨 Red Flags a Evitar

1. ❌ Notificaciones agresivas ("¡No olvides registrar!")
2. ❌ Comparaciones con otros usuarios (puede crear ansiedad)
3. ❌ Penalizaciones por no usar la app
4. ❌ Lenguaje de culpa o presión
5. ❌ Mascota triste o decepcionada
6. ❌ Perder racha por estar offline

---

## 💡 Mejoras Futuras (Solo si los datos lo justifican)

- Desafíos semanales opcionales (no obligatorios)
- Estadísticas personales (no comparativas)
- Recompensas reales (si hay patrocinadores)
- Compartir logros (opcional, nunca forzado)

