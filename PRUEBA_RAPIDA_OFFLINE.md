# ⚡ PRUEBA RÁPIDA - MODO OFFLINE (5 minutos)

## 🎯 Prueba Básica de Funcionalidad

### Paso 1: Preparación (30 segundos)
1. Abre la app
2. Inicia sesión (si no estás autenticado)
3. Ve al Home
4. Verifica que estés conectado (no deberías ver el badge "Modo Offline")

### Paso 2: Crear Registro Offline (1 minuto)
1. **Desactiva WiFi y datos móviles** en tu dispositivo
2. Deberías ver el badge "Modo Offline" en la esquina inferior derecha
3. Ve a la sección de lactancia (botón en Home)
4. Crea un nuevo registro de lactancia:
   - Completa el formulario
   - Guarda el registro
5. ✅ **Verifica:** El registro se guarda sin errores

### Paso 3: Verificar Indicadores (30 segundos)
1. Vuelve al Home
2. Deberías ver:
   - ✅ El registro que acabas de crear aparece en el dashboard
   - ✅ En la esquina superior derecha aparece el `SyncIndicator` con el número "1"
3. Toca el `SyncIndicator`
4. ✅ **Verifica:** Se abre un diálogo mostrando:
   - Estado: "Sin conexión"
   - Operaciones pendientes: "1"
   - Estado: "En espera"

### Paso 4: Sincronizar (2 minutos)
1. **Activa WiFi o datos móviles**
2. Espera 2-5 segundos
3. ✅ **Verifica:**
   - El `SyncIndicator` muestra animación de sincronización (naranja con spinner)
   - Luego desaparece o muestra check verde
   - Aparece un SnackBar verde en la parte inferior: **"1 operación sincronizada exitosamente"**

### Paso 5: Verificar en Firestore (1 minuto)
1. Abre Firebase Console → Firestore
2. Navega a: `Users` → `{tu userId}` → `situacion` → `seleccion` → `lactancia`
3. ✅ **Verifica:** El registro que creaste offline ahora aparece en Firestore

---

## ✅ RESULTADO ESPERADO

Si todos los pasos funcionan correctamente:
- ✅ Los registros se guardan offline
- ✅ Los indicadores visuales funcionan
- ✅ La sincronización automática funciona
- ✅ Las notificaciones aparecen
- ✅ Los datos se sincronizan con Firestore

---

## 🔍 VERIFICACIÓN EN LOGS

Abre la consola de desarrollo (VS Code, Android Studio, etc.) y busca estos mensajes:

### Cuando guardas offline:
```
✅ Registro de lactancia guardado localmente: {id}
📴 Sin conexión: Registro guardado localmente, se sincronizará cuando haya conexión
```

### Cuando se sincroniza:
```
🌐 OfflineSyncService: Conexión detectada, iniciando sincronización
🔄 OfflineSyncService: Procesando 1 operaciones pendientes
✅ OfflineSyncService: Operación {id} sincronizada exitosamente
✅ Sincronización completada: 1 operaciones
```

---

## 🐛 SI ALGO NO FUNCIONA

### El registro no se guarda offline:
- Verifica que `LactationService` esté usando `LactationDatabase`
- Revisa los logs para ver errores

### El SyncIndicator no aparece:
- Verifica que el widget esté en el Stack de HomePage
- Verifica que hay operaciones pendientes en la cola

### La sincronización no ocurre automáticamente:
- Verifica que `OfflineSyncService.startAutoSync()` se llamó en `main.dart`
- Verifica la conexión a internet
- Revisa los logs para ver errores

### El SnackBar no aparece:
- Verifica que `navigatorKey` esté configurado correctamente
- Verifica que el contexto esté disponible cuando se llama `_showSyncNotification`

---

## 📱 PRUEBA ADICIONAL: Perfil Offline

### Pasos:
1. Con conexión, ve al Home (esto cachea tu perfil)
2. Desactiva conexión
3. Cierra completamente la app
4. Abre la app nuevamente
5. Inicia sesión (debería funcionar offline)
6. Ve al Home
7. ✅ **Verifica:** Tu perfil e información del bebé se muestran correctamente desde cache

---

**¡Listo!** Si todas las verificaciones pasan, la funcionalidad offline está funcionando correctamente. 🎉

