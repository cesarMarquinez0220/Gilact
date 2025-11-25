# Implementación de Sonidos y Vibraciones

## 🎵 Sonidos de Libre Uso Recomendados

### Fuentes Recomendadas:
1. **Freesound.org** (https://freesound.org)
   - Licencia: Creative Commons
   - Búsquedas sugeridas:
     - "UI success sound"
     - "achievement unlock"
     - "level up sound"
     - "game notification"

2. **Zapsplat** (https://www.zapsplat.com)
   - Licencia: Gratis con registro
   - Categoría: UI/Game Sounds

3. **Mixkit** (https://mixkit.co/free-sound-effects/)
   - Licencia: Gratis para uso comercial
   - Categoría: Game Sounds

### Sonidos Necesarios:

1. **`success.mp3`** - Sonido de éxito (al ganar XP)
   - Duración: 0.3-0.5 segundos
   - Tono: Positivo, suave, tipo "ding" o "chime"
   - Uso: Cuando se gana XP

2. **`achievement.mp3`** - Sonido de logro desbloqueado
   - Duración: 0.5-0.8 segundos
   - Tono: Más celebratorio que success, tipo "fanfare" corta
   - Uso: Cuando se desbloquea un logro

3. **`level_up.mp3`** - Sonido de subida de nivel
   - Duración: 0.8-1.2 segundos
   - Tono: Especial, más largo, tipo "fanfare" o "victory"
   - Uso: Cuando se sube de nivel

4. **`trivia_correct.mp3`** - Sonido de respuesta correcta en trivia
   - Duración: 0.2-0.4 segundos
   - Tono: Positivo, corto, tipo "ping" o "tick"
   - Uso: Al responder correctamente en trivia

5. **`click.mp3`** - Sonido de click (opcional, ya tenemos SystemSound)
   - Duración: 0.1-0.2 segundos
   - Tono: Muy corto, tipo "tap"
   - Uso: Interacciones generales

### Estructura de Carpetas:
```
assets/
  sounds/
    success.mp3
    achievement.mp3
    level_up.mp3
    trivia_correct.mp3
    click.mp3 (opcional)
```

## 📳 Patrones de Vibración Implementados

### Patrones Actuales:

1. **`vibrateOnSuccess()`** - Éxito general
   - Patrón: Ligera → Pausa (80ms) → Ligera
   - Uso: XP ganado, acciones exitosas

2. **`vibrateOnAchievement()`** - Logro desbloqueado
   - Patrón: Ligera → Pausa (60ms) → Mediana → Pausa (80ms) → Ligera
   - Uso: Al desbloquear logros

3. **`vibrateOnXP()`** - Ganar XP
   - Patrón: Ligera → Pausa (50ms) → Ligera
   - Uso: Al ganar XP (más rápido que success)

4. **`vibrateOnLevelUp()`** - Subir de nivel
   - Patrón: Ligera → Pausa (50ms) → Mediana → Pausa (70ms) → Ligera → Pausa (60ms) → Mediana
   - Uso: Al subir de nivel

5. **`vibrateOnTriviaCorrect()`** - Trivia correcta
   - Patrón: Ligera → Pausa (40ms) → Ligera → Pausa (40ms) → Ligera
   - Uso: Al responder correctamente en trivia

### Características:
- ✅ Todos los patrones son sutiles y no intrusivos
- ✅ Respetan el toggle de vibración del usuario
- ✅ Tienen pausas adecuadas entre vibraciones
- ✅ Usan intensidades variadas (ligera/mediana) para crear ritmo

## 🔧 Implementación Técnica

### Servicio de Sonidos Mejorado:
El servicio actual usa `SystemSound`, pero se puede mejorar para usar archivos de audio personalizados con `audioplayers`.

### Próximos Pasos:
1. Descargar sonidos de libre uso de las fuentes recomendadas
2. Colocar en `assets/sounds/`
3. Actualizar `pubspec.yaml` para incluir los sonidos
4. Modificar `SoundService` para usar `audioplayers` en lugar de `SystemSound`
5. Implementar reproducción de sonidos personalizados

## 📝 Notas
- Los sonidos deben ser cortos (máximo 1.2 segundos)
- Volumen bajo para no ser intrusivos
- Formato recomendado: MP3 comprimido
- Todos los sonidos deben tener licencia de libre uso

