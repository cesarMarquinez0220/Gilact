# Guía de Pruebas - Sistema de Notificaciones

## 📋 Resumen de Notificaciones Implementadas

### 1. Notificación de Sueño (8 AM diaria)
- **Cuándo se programa**: Al iniciar sesión si el usuario es postparto
- **Hora**: 8:00 AM todos los días según la hora del dispositivo
- **ID**: 889
- **Comportamiento**: Se reprograma automáticamente si el usuario la elimina

### 2. Notificación de Lactancia (dinámica según edad del bebé)
- **Cuándo se programa**: Automáticamente al guardar un registro de lactancia
- **Intervalo**: Varía según la edad del bebé:
  - 0-1 mes: 2 horas
  - 1-2 meses: 2.5 horas
  - 2-3 meses: 3 horas
  - 3-4 meses: 3.5 horas
  - 4-6 meses: 4 horas
  - 6+ meses: 4.5 horas
- **Comportamiento**: Se reprograma automáticamente si el usuario la elimina

---

## 🧪 Cómo Probar las Notificaciones

### Prueba 1: Notificación de Sueño a las 8 AM

#### Opción A: Cambiar la hora del dispositivo (Recomendado para prueba rápida)

1. **Preparación**:
   - Asegúrate de estar autenticado como usuario postparto
   - Cierra completamente la aplicación

2. **Pasos**:
   - Cambia la hora del dispositivo a las 7:55 AM
   - Abre la aplicación e inicia sesión
   - La notificación debería programarse para las 8:00 AM
   - Espera 5 minutos (o cambia la hora a las 8:00 AM)
   - Deberías recibir la notificación

3. **Verificación**:
   - La notificación debe aparecer a las 8:00 AM
   - Al tocar la notificación, debe abrir el formulario de registro de sueño

#### Opción B: Usar modo de prueba (Modificar código temporalmente)

Si quieres probar sin esperar hasta las 8 AM, puedes modificar temporalmente el código:

```dart
// En sleep_notification_service.dart, línea ~434
// Cambiar temporalmente:
final horaDeseada = 8; // 8 AM
final minutosDeseados = 0;

// Por ejemplo, para probar en 2 minutos:
final horaDeseada = now.hour;
final minutosDeseados = now.minute + 2; // 2 minutos desde ahora
```

**⚠️ IMPORTANTE**: Recuerda revertir este cambio después de probar.

---

### Prueba 2: Verificar Reprogramación Automática

#### Para Notificación de Sueño (8 AM):

1. **Preparación**:
   - Inicia sesión en la app (esto programa la notificación de las 8 AM)
   - Verifica que la notificación esté programada:
     - Ve a Configuración del dispositivo → Aplicaciones → Gilact → Notificaciones
     - O usa el código de depuración (ver abajo)

2. **Pasos**:
   - Elimina la notificación programada desde la lista de notificaciones del dispositivo
   - Espera 30 minutos (o menos si modificas el intervalo de verificación)
   - La aplicación debería detectar que la notificación fue eliminada
   - La notificación debería reprogramarse automáticamente

3. **Verificación**:
   - Después de 30 minutos, verifica que la notificación vuelva a estar programada
   - Puedes verificar esto revisando las notificaciones pendientes del dispositivo

#### Para Notificación de Lactancia:

1. **Preparación**:
   - Guarda un registro de lactancia (esto programa una notificación)
   - Anota el ID de la notificación o el tiempo programado

2. **Pasos**:
   - Elimina la notificación de lactancia desde la lista de notificaciones
   - Espera 30 minutos
   - La aplicación debería detectar y reprogramar la notificación

3. **Verificación**:
   - Verifica que la notificación vuelva a estar programada
   - El tiempo programado debe ser el mismo (2 horas después de la última toma)

---

## 🔍 Código de Depuración para Verificar Notificaciones

Puedes agregar este código temporalmente en cualquier parte de la app para ver las notificaciones pendientes:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> debugPendingNotifications() async {
  final androidNotifications = FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidNotifications != null) {
    final pending = await androidNotifications.pendingNotificationRequests();
    print('📋 Notificaciones pendientes: ${pending.length}');
    for (var notification in pending) {
      print('  - ID: ${notification.id}');
      print('    Título: ${notification.title}');
      print('    Cuerpo: ${notification.body}');
      print('    Payload: ${notification.payload}');
    }
  }
}
```

Luego llama a `debugPendingNotifications()` desde cualquier parte de la app.

---

## ⚙️ Ajustar Intervalo de Verificación (Para Pruebas Rápidas)

Si quieres probar la reprogramación automática más rápido, puedes modificar temporalmente el intervalo:

**En `app_initialization_service.dart`, línea ~214:**

```dart
// Cambiar de 30 minutos a 1 minuto para pruebas:
_timer = Timer.periodic(
  const Duration(minutes: 1), // Cambiar de 30 a 1
  (_) => _verifyNotifications(),
);
```

**⚠️ IMPORTANTE**: Recuerda revertir a 30 minutos después de probar.

---

## 📱 Verificar Notificaciones en Android

### Método 1: Desde Configuración del Dispositivo
1. Ve a **Configuración** → **Aplicaciones** → **Gilact**
2. Toca **Notificaciones**
3. Verifica que los canales de notificación estén habilitados

### Método 2: Usar ADB (Android Debug Bridge)
```bash
# Ver notificaciones pendientes
adb shell dumpsys notification | grep -A 10 "Gilact"

# O más específico:
adb shell dumpsys notification | grep -A 20 "daily_sleep_reminder"
```

---

## 🐛 Solución de Problemas

### La notificación no aparece a las 8 AM:
1. Verifica que el dispositivo no esté en modo "No molestar"
2. Verifica que los permisos de notificación estén concedidos
3. Verifica que la hora del dispositivo sea correcta
4. Revisa los logs de la aplicación para ver si hay errores

### La notificación no se reprograma después de eliminarla:
1. Verifica que la verificación periódica esté activa (se inicia al abrir la app)
2. Espera al menos 30 minutos (o el intervalo configurado)
3. Revisa los logs para ver si hay errores en la verificación
4. Verifica que la app no esté en modo de ahorro de batería que pueda detener el timer

### La notificación de lactancia usa siempre 2 horas:
1. Verifica que la fecha de nacimiento del bebé esté guardada correctamente
2. Revisa los logs para ver qué fecha de nacimiento se está usando
3. Verifica que el cálculo de edad esté funcionando correctamente

---

## ✅ Checklist de Pruebas

- [ ] Notificación de sueño se programa al iniciar sesión
- [ ] Notificación de sueño aparece a las 8 AM
- [ ] Notificación de sueño se reprograma si se elimina
- [ ] Notificación de lactancia se programa al guardar registro
- [ ] Notificación de lactancia usa intervalo correcto según edad del bebé
- [ ] Notificación de lactancia se reprograma si se elimina
- [ ] Verificación periódica funciona cada 30 minutos
- [ ] Al tocar las notificaciones, se abre la pantalla correcta

---

## 📝 Notas Importantes

1. **Modo exacto vs inexacto**: Las notificaciones usan `exactAllowWhileIdle` cuando es posible, pero pueden caer a `inexact` si hay problemas de permisos o del sistema.

2. **Permisos**: Asegúrate de que la app tenga permisos de notificación y de "No optimizar batería" para que las notificaciones exactas funcionen.

3. **Timezone**: Las notificaciones usan la zona horaria local del dispositivo, así que asegúrate de que esté configurada correctamente.

4. **Background**: La verificación periódica solo funciona cuando la app está en segundo plano o cerrada si el sistema lo permite. En algunos dispositivos, puede necesitar permisos especiales.

