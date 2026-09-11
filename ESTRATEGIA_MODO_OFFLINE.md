# 📱 ESTRATEGIA DE MODO OFFLINE - GILACT

## 📊 ANÁLISIS DE LA APLICACIÓN ACTUAL

### ✅ **FUNCIONALIDADES OFFLINE YA IMPLEMENTADAS**

#### 1. **Autenticación Offline** ✅
- **Servicio**: `OfflineSessionService`
- **Almacenamiento**: `SharedPreferences` + `OfflineUserLocalDataSource` (SQLite)
- **Funcionalidades**:
  - Login offline con validación local de credenciales (SHA-256)
  - Sesiones persistentes (30 días de validez)
  - Tokens de sesión locales
  - Validación de contraseña sin conexión
- **Estado**: ✅ **COMPLETO**

#### 2. **Videos Offline** ✅
- **Servicios**: 
  - `VideoDownloadService` - Descarga y encriptación
  - `VideoEncryptionService` - Encriptación AES-256
  - `VideoOfflineLocalDataSource` - Almacenamiento SQLite
- **Funcionalidades**:
  - Descarga de videos desde YouTube
  - Encriptación de videos (AES-256)
  - Almacenamiento local encriptado
  - Reproducción offline con desencriptación en streaming
  - Metadatos de videos en SQLite
  - Gestión de espacio de almacenamiento
- **Estado**: ✅ **COMPLETO**

#### 3. **Progreso de Videos Offline** ⚠️
- **Servicio**: `VideoProgressService`
- **Almacenamiento**: `LeccionesProvider` (SharedPreferences) + Firestore
- **Funcionalidades**:
  - Guardado local de progreso en `SharedPreferences`
  - Carga desde Firestore cuando hay conexión
  - **PROBLEMA**: No sincroniza cambios offline con Firestore cuando vuelve la conexión
- **Estado**: ⚠️ **PARCIAL** - Falta sincronización bidireccional

#### 4. **Detección de Conectividad** ✅
- **Servicio**: `ConnectivityService`
- **Funcionalidades**:
  - Detección de estado de conexión
  - Stream de cambios de conectividad
  - Diferenciación WiFi/Móvil
- **Estado**: ✅ **COMPLETO**

#### 5. **Badge Offline** ✅
- **Widget**: `OfflineBadge`
- **Funcionalidades**:
  - Indicador visual de estado offline
  - Actualización automática según conectividad
- **Estado**: ✅ **COMPLETO**

---

### ❌ **FUNCIONALIDADES QUE REQUIEREN RED (SIN SOPORTE OFFLINE)**

#### 1. **Registros de Lactancia** ⚠️
- **Servicio**: `LactationService`
- **Dependencia**: Firestore (`Users/{userId}/situacion/seleccion/lactancia`)
- **Base de Datos Local**: `LactationDatabase` (SQLite) - ✅ **YA EXISTE**
- **Operaciones**:
  - Guardar registros de lactancia
  - Obtener historial de lactancia
  - Actualizar registros
  - Eliminar registros
- **Impacto**: **ALTO** - Funcionalidad core de la app
- **Estado**: ⚠️ **PARCIAL** - Tiene almacenamiento local pero NO sincroniza con Firestore
- **Problema**: Los registros se guardan localmente pero no se sincronizan cuando vuelve la conexión

#### 2. **Registros de Sueño** ❌
- **Servicio**: `SleepNotificationService`
- **Dependencia**: Firestore
- **Operaciones**:
  - Guardar registros de sueño
  - Obtener historial de sueño
  - Notificaciones programadas
- **Impacto**: **ALTO** - Funcionalidad core de la app
- **Estado**: ❌ **SIN SOPORTE OFFLINE**

#### 3. **Chatbot** ❌
- **Servicio**: `ChatbotRemoteDataSource`
- **Dependencia**: Firestore (`chatbot_knowledge`, `Users/{userId}/chat_history`)
- **Operaciones**:
  - Obtener base de conocimiento
  - Guardar historial de chat
  - Buscar respuestas
- **Impacto**: **MEDIO** - Funcionalidad secundaria
- **Estado**: ❌ **SIN SOPORTE OFFLINE**

#### 4. **Tips (Consejos)** ❌
- **Servicio**: `TipRemoteDataSource`
- **Dependencia**: Firestore (`tips`, `Users/{userId}/favorite_tips`)
- **Operaciones**:
  - Obtener todos los tips
  - Buscar tips
  - Marcar como favoritos
- **Impacto**: **MEDIO** - Funcionalidad secundaria
- **Estado**: ❌ **SIN SOPORTE OFFLINE**

#### 5. **Contenido Educativo** ❌
- **Servicio**: `EducationalContentRemoteDataSource`
- **Dependencia**: Firestore (`educational_content`)
- **Operaciones**:
  - Obtener contenido educativo
  - Marcar como completado
  - Estadísticas
- **Impacto**: **MEDIO** - Funcionalidad secundaria
- **Estado**: ❌ **SIN SOPORTE OFFLINE**

#### 6. **Perfil de Usuario** ❌
- **Servicio**: `UserProfileRemoteDataSource`
- **Dependencia**: Firestore
- **Operaciones**:
  - Actualizar perfil
  - Obtener perfil
- **Impacto**: **BAJO** - Funcionalidad secundaria
- **Estado**: ❌ **SIN SOPORTE OFFLINE**

#### 7. **Onboarding** ❌
- **Servicio**: `UserSubcollectionsService`
- **Dependencia**: Firestore (`Users/{userId}/situacion`)
- **Operaciones**:
  - Guardar selección de situación
  - Formularios preparto/postparto
- **Impacto**: **BAJO** - Solo al inicio
- **Estado**: ❌ **SIN SOPORTE OFFLINE**

---

## 🎯 ESTRATEGIA DE IMPLEMENTACIÓN OFFLINE

### **FASE 1: Sincronización de Datos Críticos** 🔴 **PRIORIDAD ALTA**

#### 1.1 **Sistema de Cola de Sincronización**
```dart
// Estructura propuesta
class SyncQueueService {
  // Cola de operaciones pendientes
  // Sincronización automática cuando hay conexión
  // Manejo de conflictos
  // Reintentos automáticos
}
```

**Implementación**:
- **Tabla SQLite**: `sync_queue`
  - `id` (PRIMARY KEY)
  - `operation_type` (CREATE, UPDATE, DELETE)
  - `collection_path` (ej: "lactancia", "sueño")
  - `document_id` (si existe)
  - `data` (JSON con los datos)
  - `status` (PENDING, SYNCING, COMPLETED, FAILED)
  - `retry_count`
  - `created_at`
  - `last_attempt_at`
  - `error_message`

#### 1.2 **Almacenamiento Local de Registros de Lactancia**
```dart
// Estructura propuesta
class LactationOfflineLocalDataSource {
  // Guardar registros localmente en SQLite
  // Sincronizar con Firestore cuando hay conexión
  // Manejar conflictos (última escritura gana)
}
```

**Tabla SQLite**: `lactation_records`
- Campos del `LactationRecord` entity
- `sync_status` (SYNCED, PENDING, CONFLICT)
- `firestore_id` (NULL si no está sincronizado)
- `local_id` (UUID temporal)
- `created_at_local`
- `updated_at_local`
- `last_sync_at`

#### 1.3 **Almacenamiento Local de Registros de Sueño**
```dart
// Similar a lactancia
class SleepOfflineLocalDataSource {
  // Guardar registros localmente
  // Sincronizar con Firestore
}
```

**Tabla SQLite**: `sleep_records`
- Similar estructura a `lactation_records`

---

### **FASE 2: Cache de Perfil de Usuario e Información del Bebé** 🟡 **PRIORIDAD ALTA**

#### 2.1 **Cache de Perfil de Usuario**
```dart
class UserProfileOfflineLocalDataSource {
  // Guardar perfil completo del usuario
  // Incluir información del bebé (postparto)
  // Datos de situación (preparto/postparto)
  // Servir desde cache cuando está offline
  // Actualizar cache cuando hay conexión
}
```

**Tabla SQLite**: `user_profile_cache`
- Todos los campos de `UserProfile`
- `situation_data` (JSON con datos de situación)
- `baby_info` (JSON con información del bebé para postparto)
- `cached_at` (timestamp de cuando se guardó)
- `last_sync_at` (timestamp de última sincronización)

#### 2.2 **Modificar UserProfileBloc para soporte offline**
```dart
// Lógica offline-first
Future<void> loadUserProfile() async {
  if (await _connectivityService.isConnected()) {
    final profile = await _remoteDataSource.getUserProfile();
    await _offlineDataSource.cacheUserProfile(profile); // Actualizar cache
    emit(UserProfileLoaded(profile));
  } else {
    final cachedProfile = await _offlineDataSource.getCachedUserProfile();
    if (cachedProfile != null) {
      emit(UserProfileLoaded(cachedProfile)); // Servir desde cache
    } else {
      emit(UserProfileFailure('No hay conexión y no hay datos en cache'));
    }
  }
}
```

---

### **FASE 3: Sincronización Inteligente** 🟢 **PRIORIDAD MEDIA-BAJA**

#### 3.1 **Servicio de Sincronización Centralizado**
```dart
class OfflineSyncService {
  // Monitorear conectividad
  // Sincronizar automáticamente cuando hay conexión
  // Priorizar operaciones críticas
  // Manejar errores y reintentos
  // Notificar al usuario del estado de sincronización
}
```

**Características**:
- Sincronización en background
- Priorización de operaciones (CREATE > UPDATE > DELETE)
- Reintentos exponenciales
- Límite de reintentos (ej: 5 intentos)
- Notificaciones de estado al usuario

#### 3.2 **Manejo de Conflictos**
```dart
class ConflictResolutionService {
  // Detectar conflictos (mismo documento modificado offline y online)
  // Estrategias:
  // - Última escritura gana (Last Write Wins)
  // - Merge inteligente (para campos específicos)
  // - Solicitar al usuario (para casos críticos)
}
```

**Estrategias**:
1. **Last Write Wins (LWW)**: Por defecto, la última modificación gana
2. **Merge Inteligente**: Para campos específicos (ej: arrays de registros)
3. **Usuario Decide**: Para conflictos críticos, mostrar diálogo

---

### **FASE 4: Optimizaciones y UX** 🔵 **PRIORIDAD BAJA**

#### 4.1 **Indicadores de Estado Offline**
- Badge offline (ya implementado) ✅
- Indicadores en cada pantalla de estado de sincronización
- Notificaciones de sincronización completada
- Contador de operaciones pendientes

#### 4.2 **Precarga Inteligente**
- Precargar contenido cuando hay WiFi
- Detectar conexión WiFi para descargas grandes
- Cache automático de contenido frecuentemente accedido

#### 4.3 **Gestión de Espacio**
- Limpiar cache antiguo automáticamente
- Permitir al usuario gestionar espacio
- Mostrar uso de almacenamiento

---

## 📋 PLAN DE IMPLEMENTACIÓN DETALLADO

### **PRIORIDAD 1: Registros de Lactancia y Sueño** 🔴

#### **⚠️ IMPORTANTE: Ya existe `LactationDatabase`**
- **Archivo**: `lib/features/lactation/data/datasources/lactation_database.dart`
- **Estado**: ✅ Base de datos SQLite ya implementada
- **Problema**: `LactationService` NO usa esta base local, solo guarda en Firestore
- **Solución**: Integrar `LactationDatabase` con `LactationService` y agregar sincronización

#### **Paso 1.1: Modificar LactationService para usar LactationDatabase**
```dart
// Modificar lib/features/lactation/data/services/lactation_service.dart
class LactationService {
  final LactationDatabase _localDatabase = LactationDatabase();
  
  Future<String> saveRecord(LactationRecord record) async {
    // SIEMPRE guardar localmente primero
    await _localDatabase.insertRecord(record);
    
    // Si hay conexión, guardar también en Firestore
    if (await _connectivityService.isConnected()) {
      try {
        final firestoreId = await _saveToFirestore(record);
        // Marcar como sincronizado (necesita campo sync_status en tabla)
        return firestoreId;
      } catch (e) {
        // Si falla Firestore, el registro queda local para sincronizar después
        print('⚠️ Error guardando en Firestore, quedará pendiente de sincronización');
      }
    } else {
      // Agregar a cola de sincronización
      await _syncQueue.addOperation(/* ... */);
    }
    
    return record.id; // Retornar ID local
  }
}
```

#### **Paso 1.2: Extender LactationDatabase con campos de sincronización**
```dart
// Agregar campos a la tabla lactation_records:
// - firestore_id (TEXT, nullable) - ID en Firestore cuando está sincronizado
// - sync_status (TEXT) - 'SYNCED', 'PENDING', 'CONFLICT'
// - last_sync_at (INTEGER, nullable) - Timestamp de última sincronización
// - local_id (TEXT) - ID local único (UUID)
```

#### **Paso 1.2: Modificar LactationService**
```dart
// Agregar lógica offline-first
class LactationService {
  Future<String> saveRecord(LactationRecord record) async {
    if (await _connectivityService.isConnected()) {
      // Guardar en Firestore directamente
      return await _saveToFirestore(record);
    } else {
      // Guardar localmente y agregar a cola de sincronización
      final localId = await _offlineDataSource.saveRecordLocally(record);
      await _syncQueue.addOperation(/* ... */);
      return localId;
    }
  }
}
```

#### **Paso 1.3: Crear SyncQueueService**
```dart
// lib/core/services/sync_queue_service.dart
class SyncQueueService {
  Future<void> addOperation(SyncOperation operation)
  Future<void> processQueue() // Procesar cuando hay conexión
  Stream<int> get pendingOperationsCount
}
```

#### **Paso 1.4: Integrar Sincronización Automática**
```dart
// En ConnectivityService o nuevo servicio
class OfflineSyncService {
  void startAutoSync() {
    _connectivityService.connectivityStream.listen((isConnected) {
      if (isConnected) {
        _syncQueueService.processQueue();
      }
    });
  }
}
```

---

### **PRIORIDAD 2: Cache de Perfil de Usuario e Información del Bebé** 🟡

#### **Paso 2.1: Crear UserProfileOfflineLocalDataSource**
```dart
// lib/features/user/data/datasources/user_profile_offline_local_data_source.dart
class UserProfileOfflineLocalDataSource {
  Future<void> cacheUserProfile(UserProfile profile)
  Future<UserProfile?> getCachedUserProfile()
  Future<bool> isCacheValid() // Verificar si el cache es reciente
  Future<void> clearCache()
}
```

#### **Paso 2.2: Modificar UserProfileBloc**
```dart
// Lógica offline-first
Future<void> loadUserProfile() async {
  if (await _connectivityService.isConnected()) {
    final profile = await _remoteDataSource.getUserProfile();
    await _offlineDataSource.cacheUserProfile(profile); // Actualizar cache
    emit(UserProfileLoaded(profile));
  } else {
    final cachedProfile = await _offlineDataSource.getCachedUserProfile();
    if (cachedProfile != null) {
      emit(UserProfileLoaded(cachedProfile)); // Servir desde cache
    } else {
      emit(UserProfileFailure('No hay conexión y no hay datos en cache'));
    }
  }
}
```

---

### **PRIORIDAD 3: Chatbot - Mensaje de Conexión Requerida** 🟢

#### **Paso 3.1: Agregar Validación de Conectividad en Chatbot**
```dart
// Modificar ChatbotBloc o ChatbotPage
Future<void> sendMessage(String message) async {
  if (!await _connectivityService.isConnected()) {
    emit(ChatbotError('Es necesario tener conexión a internet para una respuesta'));
    return;
  }
  // ... lógica normal del chatbot
}
```

---

## 🏗️ ARQUITECTURA PROPUESTA

### **Patrón: Offline-First**

```
┌─────────────────────────────────────────┐
│         UI Layer (Widgets)              │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Repository Layer (Offline-First)    │
│  ┌───────────────────────────────────┐  │
│  │ 1. Verificar conectividad          │  │
│  │ 2. Si online: Remote + Cache       │  │
│  │ 3. Si offline: Local Data Source   │  │
│  └───────────────────────────────────┘  │
└─────┬───────────────────┬───────────────┘
      │                   │
┌─────▼──────┐    ┌───────▼──────────────┐
│   Remote   │    │   Local Data Source  │
│  DataSource│    │   (SQLite)           │
│ (Firestore)│    │                      │
└────────────┘    └──────────────────────┘
                        │
                  ┌─────▼──────────────┐
                  │  Sync Queue Service│
                  │  (Sincronización)  │
                  └────────────────────┘
```

---

## 📦 ESTRUCTURA DE BASE DE DATOS SQLITE

### **Tablas Propuestas**:

1. **`sync_queue`** - Cola de sincronización (NUEVA)
2. **`lactation_records`** - ✅ Ya existe, pero necesita campos de sincronización
3. **`sleep_records`** - Registros de sueño offline (NUEVA)
4. **`user_profile_cache`** - Cache de perfil de usuario e información del bebé (NUEVA)
5. **`offline_videos`** - ✅ Ya existe
6. **`offline_users`** - ✅ Ya existe

---

## 🔄 FLUJO DE SINCRONIZACIÓN

### **Escenario 1: Usuario Crea Registro Offline**
```
1. Usuario crea registro → Guarda en SQLite local
2. Agrega operación a sync_queue (status: PENDING)
3. Cuando hay conexión → SyncQueueService procesa
4. Guarda en Firestore → Actualiza sync_queue (status: COMPLETED)
5. Actualiza registro local con firestore_id
```

### **Escenario 2: Usuario Modifica Registro Offline**
```
1. Usuario modifica registro → Actualiza en SQLite local
2. Agrega operación UPDATE a sync_queue
3. Cuando hay conexión → Sincroniza con Firestore
4. Si hay conflicto → Aplicar estrategia de resolución
```

### **Escenario 3: Cache de Perfil de Usuario**
```
1. Usuario carga Home (online) → Descarga perfil y cachea
2. Usuario carga Home (offline) → Sirve desde cache
3. Información del bebé se muestra desde cache
4. Próxima conexión → Actualizar cache
```

### **Escenario 4: Chatbot Offline**
```
1. Usuario intenta enviar mensaje (offline) → Muestra mensaje "Es necesario tener conexión a internet"
2. No se permite interacción hasta que haya conexión
```

---

## ⚠️ CONSIDERACIONES IMPORTANTES

### **1. Gestión de Espacio**
- Videos encriptados ocupan mucho espacio
- Cache de contenido puede crecer
- Implementar límites y limpieza automática

### **2. Seguridad**
- Videos ya están encriptados ✅
- Datos sensibles (lactancia) deben encriptarse localmente
- Considerar encriptación de base de datos SQLite

### **3. Performance**
- Índices en tablas SQLite para búsquedas rápidas
- Paginación para listas grandes
- Lazy loading de datos

### **4. Experiencia de Usuario**
- Indicadores claros de estado offline
- Notificaciones de sincronización
- Manejo de errores amigable
- No bloquear UI durante sincronización

---

## 🎯 RESUMEN DE PRIORIDADES

### **🔴 CRÍTICO (Implementar Primero)**
1. ✅ Autenticación offline (YA IMPLEMENTADO)
2. ✅ Videos offline (YA IMPLEMENTADO)
3. ✅ Historial de videos offline (YA IMPLEMENTADO - muestra solo descargados)
4. ❌ Registros de lactancia offline + sincronización
5. ❌ Registros de sueño offline + sincronización
6. ❌ Cache de perfil de usuario e información del bebé (Home)
7. ⚠️ Sincronización de progreso de videos (mejorar)

### **🟡 IMPORTANTE (Segunda Fase)**
8. Sistema de sincronización centralizado
9. Manejo de conflictos
10. Chatbot - Mensaje de conexión requerida

### **🟢 NO REQUERIDO**
- ❌ Cache de Tips (información estática, no crítica)
- ❌ Cache de Contenido Educativo (lecciones requieren internet para videos)
- ❌ Chatbot offline completo (solo mensaje de conexión requerida)

---

## 📝 PRÓXIMOS PASOS RECOMENDADOS

### **FASE 1: Datos Críticos** 🔴
1. **Integrar `LactationDatabase` con `LactationService`** (offline-first)
2. **Crear `SyncQueueService`** para sincronización automática
3. **Agregar campos de sincronización a `lactation_records`**
4. **Implementar sincronización automática de registros de lactancia**
5. **Crear `SleepOfflineLocalDataSource`** y repetir proceso para registros de sueño
6. **Implementar cache de perfil de usuario e información del bebé**

### **FASE 2: Mejoras y UX** 🟡
7. **Agregar mensaje de conexión requerida en Chatbot**
8. **Mejorar sincronización de progreso de videos**
9. **Indicadores de estado de sincronización**
10. **Manejo de conflictos en sincronización**

---

## 🔧 HERRAMIENTAS Y DEPENDENCIAS NECESARIAS

### **Ya Disponibles** ✅
- `sqflite` - Base de datos SQLite
- `shared_preferences` - Preferencias locales
- `connectivity_plus` - Detección de conectividad
- `crypto` - Encriptación
- `encrypt` - Encriptación AES

### **Posibles Adiciones** (Opcional)
- `drift` - ORM para SQLite (más robusto que sqflite directo)
- `workmanager` - Tareas en background para sincronización
- `hive` - Base de datos NoSQL local (alternativa a SQLite)

---

## 💡 RECOMENDACIONES FINALES

1. **Enfoque Incremental**: Implementar funcionalidad por funcionalidad
2. **Testing Offline**: Probar cada feature sin conexión
3. **Manejo de Errores**: Errores claros y recuperables
4. **Documentación**: Documentar cada decisión de diseño
5. **Métricas**: Tracking de uso offline vs online

---

**Fecha de Análisis**: 2024
**Versión del Documento**: 1.0

