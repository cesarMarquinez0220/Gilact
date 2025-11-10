# 🧪 GUÍA DE PRUEBAS - MODO OFFLINE

## 📋 Preparación

1. **Asegúrate de tener la app compilada y funcionando**
2. **Ten acceso al dispositivo/emulador para activar/desactivar WiFi/Datos**
3. **Ten una cuenta de usuario creada y con sesión iniciada**

---

## 🧪 PRUEBA 1: Registros de Lactancia Offline

### Objetivo: Verificar que los registros de lactancia se guarden localmente y se sincronicen cuando hay conexión

### Pasos:

1. **Preparación:**
   - Abre la app y asegúrate de estar autenticado
   - Verifica que estés conectado a internet (deberías ver el badge "Modo Offline" desaparecer)

2. **Desactivar conexión:**
   - Desactiva WiFi y datos móviles en el dispositivo
   - Deberías ver el badge "Modo Offline" aparecer en la esquina inferior derecha

3. **Crear registro offline:**
   - Ve a la sección de lactancia (Home → Botón de lactancia)
   - Crea un nuevo registro de lactancia
   - Completa el formulario y guarda
   - ✅ **Resultado esperado:** El registro se guarda sin errores, aunque no haya conexión

4. **Verificar guardado local:**
   - Ve al Home
   - Deberías ver el registro que acabas de crear en el dashboard de lactancia
   - ✅ **Resultado esperado:** El registro aparece inmediatamente, incluso sin conexión

5. **Verificar cola de sincronización:**
   - En la esquina superior derecha, deberías ver el `SyncIndicator` con un número (ej: "1")
   - Toca el indicador para ver los detalles
   - ✅ **Resultado esperado:** Muestra "1 operación pendiente"

6. **Activar conexión y sincronizar:**
   - Activa WiFi o datos móviles
   - Espera 2-5 segundos
   - ✅ **Resultado esperado:** 
     - El `SyncIndicator` debería mostrar animación de sincronización
     - Luego desaparecer o mostrar "0"
     - Deberías ver un SnackBar verde: "1 operación sincronizada exitosamente"

7. **Verificar sincronización en Firestore:**
   - Abre la consola de Firebase
   - Ve a Firestore → Users → {tu userId} → situacion → seleccion → lactancia
   - ✅ **Resultado esperado:** El registro aparece en Firestore con los datos correctos

---

## 🧪 PRUEBA 2: Registros de Sueño Offline

### Objetivo: Verificar que los registros de sueño se guarden localmente y se sincronicen

### Pasos:

1. **Desactivar conexión:**
   - Desactiva WiFi y datos móviles

2. **Crear registro de sueño:**
   - Ve a la sección de registro de sueño (desde notificación o manualmente)
   - Completa el formulario de sueño del bebé
   - Guarda el registro
   - ✅ **Resultado esperado:** Se guarda sin errores

3. **Verificar sincronización:**
   - Activa conexión
   - Espera la sincronización automática
   - ✅ **Resultado esperado:** 
     - SnackBar de sincronización exitosa
     - El registro aparece en Firestore en: Users → {userId} → situacion → seleccion → sueno_diario

---

## 🧪 PRUEBA 3: Perfil de Usuario e Información del Bebé Offline

### Objetivo: Verificar que el perfil y la información del bebé se muestren desde cache cuando está offline

### Pasos:

1. **Preparación (con conexión):**
   - Asegúrate de estar conectado
   - Ve al Home
   - Verifica que se muestre tu perfil e información del bebé (si eres postparto)
   - Esto cachea el perfil localmente

2. **Desactivar conexión:**
   - Desactiva WiFi y datos móviles
   - Cierra completamente la app (no solo minimizar)
   - Abre la app nuevamente

3. **Verificar cache:**
   - Inicia sesión (debería funcionar offline si ya tienes sesión guardada)
   - Ve al Home
   - ✅ **Resultado esperado:** 
     - El perfil se carga desde cache
     - La información del bebé se muestra correctamente
     - No aparece error de "No hay conexión"

4. **Verificar información del bebé:**
   - Si eres postparto, deberías ver el widget `PostpartoProfileWidget` con:
     - Nombre del bebé
     - Edad gestacional
     - Fecha de nacimiento
     - Lugar de nacimiento
     - Peso
   - ✅ **Resultado esperado:** Toda la información se muestra correctamente desde cache

---

## 🧪 PRUEBA 4: Sincronización Automática

### Objetivo: Verificar que la sincronización se active automáticamente cuando hay conexión

### Pasos:

1. **Crear múltiples registros offline:**
   - Desactiva conexión
   - Crea 3-4 registros de lactancia
   - ✅ **Resultado esperado:** Todos se guardan localmente

2. **Verificar contador:**
   - El `SyncIndicator` debería mostrar "3" o "4" (número de operaciones pendientes)

3. **Activar conexión:**
   - Activa WiFi o datos móviles
   - **NO hagas nada más**, solo espera

4. **Observar sincronización automática:**
   - En 2-5 segundos, deberías ver:
     - El `SyncIndicator` animándose (indicando sincronización)
     - El contador disminuyendo
     - Finalmente, un SnackBar: "4 operaciones sincronizadas exitosamente"
   - ✅ **Resultado esperado:** Todas las operaciones se sincronizan automáticamente sin intervención del usuario

---

## 🧪 PRUEBA 5: Resolución de Conflictos

### Objetivo: Verificar que los conflictos se detecten y resuelvan correctamente

### Pasos:

1. **Preparación:**
   - Asegúrate de tener un registro de lactancia existente en Firestore
   - Anota el ID del documento en Firestore

2. **Modificar registro offline:**
   - Desactiva conexión
   - Modifica un registro existente (cambia duración, notas, etc.)
   - Guarda los cambios
   - ✅ **Resultado esperado:** Se guarda localmente y se agrega a la cola como UPDATE

3. **Modificar el mismo registro en Firestore (simular otro dispositivo):**
   - Activa conexión temporalmente
   - Ve a Firestore Console
   - Modifica el mismo registro directamente en Firestore (cambia otro campo)
   - Guarda en Firestore
   - Desactiva conexión nuevamente

4. **Sincronizar:**
   - Activa conexión
   - La sincronización debería detectar el conflicto
   - ✅ **Resultado esperado:** 
     - En los logs deberías ver: "⚠️ OfflineSyncService: Conflicto detectado, resolviendo..."
     - El conflicto se resuelve usando "Last Write Wins"
     - La versión más reciente (por timestamp) se guarda en Firestore

---

## 🧪 PRUEBA 6: Indicadores de Sincronización

### Objetivo: Verificar que los indicadores visuales funcionen correctamente

### Pasos:

1. **Estado inicial (sin operaciones pendientes):**
   - Con conexión activa y sin operaciones pendientes
   - ✅ **Resultado esperado:** El `SyncIndicator` NO se muestra (o muestra check verde)

2. **Con operaciones pendientes:**
   - Desactiva conexión
   - Crea un registro
   - ✅ **Resultado esperado:** 
     - `SyncIndicator` aparece en la esquina superior derecha
     - Muestra el número de operaciones pendientes
     - Color azul con icono de nube

3. **Durante sincronización:**
   - Activa conexión
   - ✅ **Resultado esperado:** 
     - `SyncIndicator` muestra animación de carga (CircularProgressIndicator)
     - Color naranja

4. **Sincronización completada:**
   - Espera a que termine
   - ✅ **Resultado esperado:** 
     - `SyncIndicator` desaparece o muestra check verde
     - SnackBar de éxito aparece

5. **Tocar el indicador:**
   - Toca el `SyncIndicator` cuando hay operaciones pendientes
   - ✅ **Resultado esperado:** 
     - Se abre un diálogo con:
       - Estado de conexión
       - Número de operaciones pendientes
       - Estado de sincronización
       - Botón "Sincronizar Ahora"

---

## 🧪 PRUEBA 7: Múltiples Operaciones y Reintentos

### Objetivo: Verificar que el sistema maneje múltiples operaciones y reintentos

### Pasos:

1. **Crear múltiples registros:**
   - Desactiva conexión
   - Crea 5 registros de lactancia
   - Crea 3 registros de sueño
   - ✅ **Resultado esperado:** Todos se guardan localmente

2. **Verificar cola:**
   - El `SyncIndicator` debería mostrar "8" operaciones pendientes

3. **Sincronización parcial (simular fallo):**
   - Activa conexión
   - Si alguna operación falla, debería:
     - Reintentar automáticamente (hasta 5 veces)
     - Si falla después de 5 intentos, marcarla como fallida permanentemente
   - ✅ **Resultado esperado:** 
     - Las operaciones exitosas se sincronizan
     - Las fallidas se reintentan
     - SnackBar muestra resultados

---

## 🧪 PRUEBA 8: Cache de Perfil - Actualización

### Objetivo: Verificar que el cache se actualice cuando hay conexión

### Pasos:

1. **Modificar perfil online:**
   - Con conexión activa
   - Modifica tu perfil o información del bebé en Firestore Console
   - O modifica desde la app

2. **Cargar perfil:**
   - En la app, el perfil debería actualizarse
   - ✅ **Resultado esperado:** El cache se actualiza con los nuevos datos

3. **Verificar offline:**
   - Desactiva conexión
   - Cierra y abre la app
   - ✅ **Resultado esperado:** Se muestra la versión actualizada desde cache

---

## 🔍 VERIFICACIÓN EN LOGS

Para ver los logs detallados, abre la consola de desarrollo y busca:

### Logs de Sincronización:
- `🔄 OfflineSyncService: Procesando X operaciones pendientes`
- `✅ OfflineSyncService: Operación X sincronizada exitosamente`
- `⚠️ OfflineSyncService: Conflicto detectado, resolviendo...`
- `✅ Sincronización completada: X operaciones`

### Logs de Guardado Offline:
- `✅ Registro de lactancia guardado localmente: {id}`
- `📴 Sin conexión: Registro guardado localmente, se sincronizará cuando haya conexión`
- `✅ Registro de lactancia sincronizado con Firestore: {id}`

### Logs de Cache:
- `✅ UserProfileBloc: Perfil cargado desde cache`
- `📴 UserProfileBloc: Sin conexión, cargando desde cache`

---

## ⚠️ PROBLEMAS COMUNES Y SOLUCIONES

### Problema: El SyncIndicator no aparece
**Solución:** 
- Verifica que hay operaciones pendientes: `SyncQueueService.getPendingOperationsCount()`
- Verifica que el widget esté en el Stack de HomePage

### Problema: Los registros no se sincronizan
**Solución:**
- Verifica la conexión a internet
- Revisa los logs para ver errores específicos
- Verifica que `OfflineSyncService.startAutoSync()` se haya llamado en `main.dart`

### Problema: El perfil no se muestra offline
**Solución:**
- Asegúrate de haber cargado el perfil al menos una vez con conexión
- Verifica que el cache se haya guardado: `UserProfileOfflineLocalDataSource.getCachedUserProfile()`

### Problema: Conflictos no se resuelven
**Solución:**
- Verifica que los timestamps estén presentes en los datos
- Revisa los logs de `ConflictResolutionService`

---

## 📊 CHECKLIST DE PRUEBAS

- [ ] Registros de lactancia se guardan offline
- [ ] Registros de lactancia se sincronizan cuando hay conexión
- [ ] Registros de sueño se guardan offline
- [ ] Registros de sueño se sincronizan cuando hay conexión
- [ ] Perfil de usuario se muestra desde cache offline
- [ ] Información del bebé se muestra desde cache offline
- [ ] SyncIndicator muestra contador correcto
- [ ] SyncIndicator muestra estado de sincronización
- [ ] Notificaciones de sincronización aparecen
- [ ] Sincronización automática funciona
- [ ] Conflictos se detectan y resuelven
- [ ] Reintentos automáticos funcionan
- [ ] Diálogo de detalles de sincronización funciona
- [ ] Botón "Sincronizar Ahora" funciona

---

## 🎯 PRUEBA RÁPIDA (5 minutos)

Si quieres una prueba rápida:

1. **Desactiva conexión**
2. **Crea 1 registro de lactancia**
3. **Verifica que aparece en Home**
4. **Verifica que SyncIndicator muestra "1"**
5. **Activa conexión**
6. **Espera 5 segundos**
7. **Verifica SnackBar de éxito**
8. **Verifica que SyncIndicator desaparece**
9. **Verifica en Firestore que el registro existe**

✅ Si todos estos pasos funcionan, la funcionalidad básica está correcta.

---

**¡Listo para probar!** 🚀

