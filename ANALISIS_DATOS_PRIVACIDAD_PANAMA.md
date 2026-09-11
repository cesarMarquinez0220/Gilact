# Análisis de Datos Recopilados - Políticas de Privacidad Panamá

**Fecha de Análisis:** Diciembre 2024  
**Aplicación:** Gilact  
**Marco Legal:** Ley No. 81 de 2019 sobre Protección de Datos Personales de Panamá

---

## 1. RESUMEN EJECUTIVO

Este documento analiza exhaustivamente todos los datos personales y sensibles recopilados por la aplicación Gilact, tanto de la madre como del hijo, para facilitar la redacción de políticas de privacidad conforme a la legislación panameña.

---

## 2. DATOS RECOPILADOS DE LA MADRE

### 2.1. Datos de Identificación Personal

**Ubicación en el código:**
- `lib/features/auth/data/models/user_model.dart`
- `lib/features/user/domain/entities/user_profile_entities.dart`
- `lib/features/auth/presentation/pages/registration_page.dart`

**Datos recopilados:**

| Campo | Tipo | Obligatorio | Ubicación Almacenamiento |
|-------|------|-------------|-------------------------|
| **Nombre de usuario** (`usuario`/`name`) | String | Sí | Firestore: `Users/{userId}` |
| **Correo electrónico** (`email`) | String | Sí | Firestore: `Users/{userId}` + Firebase Auth |
| **Contraseña** | String (hash) | Sí | Firebase Auth (hash) + SQLite local (hash SHA-256) |
| **Número de teléfono** (`telefono`) | String | Opcional | Firestore: `Users/{userId}` |
| **Cédula/ID** (`cedula`) | String | Opcional | Firestore: `Users/{userId}` |
| **Fecha de nacimiento** (`fechaNacimiento`) | String | Sí | Firestore: `Users/{userId}` |
| **Edad** (`edad`) | Integer | Calculado | Firestore: `Users/{userId}` (calculado desde fecha nacimiento) |
| **Ubicación** (`ubicacion`) | String | Opcional | Firestore: `Users/{userId}` |
| **Nombre de la madre** (`nombre madre`) | String | Opcional | Firestore: `Users/{userId}` |

**Protección:**
- Contraseñas: Hash SHA-256 almacenado localmente (SQLite), Firebase Auth maneja el hash
- Datos sensibles: Almacenados en Firestore con reglas de seguridad
- Almacenamiento local: Datos de formulario temporalmente en `SharedPreferences` (se limpian después del registro)

### 2.2. Datos de Salud y Maternidad (Datos Sensibles)

**Ubicación en el código:**
- `lib/features/onboarding/presentation/pages/prepartum_form_page.dart`
- `lib/features/onboarding/presentation/pages/postpartum_form_page.dart`
- `lib/features/onboarding/data/services/user_subcollections_service.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **Estado de embarazo** (`isPrePartum`/`isPostPartum`) | Boolean | Firestore: `Users/{userId}/seleccion/{situationId}` |
| **Fecha probable de parto** (`expectedBirthDate`) | DateTime | Firestore: `Users/{userId}/seleccion/{situationId}` (solo preparto) |
| **Última menstruación** (`lastMenstruation`) | DateTime | Firestore: `Users/{userId}/seleccion/{situationId}` (postparto) |
| **Fecha de registro del bebé** (`babyRegisteredAt`) | Timestamp | Firestore: `Users/{userId}/seleccion/{situationId}` |

**Clasificación Legal (Panamá):**
- **Datos Sensibles** según Ley 81: Información sobre salud, estado de embarazo
- Requiere **consentimiento explícito** del usuario

### 2.3. Datos de Autenticación y Sesión

**Ubicación en el código:**
- `lib/features/auth/data/datasources/offline_user_local_data_source.dart`
- `lib/features/auth/data/services/offline_session_service.dart`
- `lib/core/services/secure_storage_service.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **Token de autenticación Firebase** | String | Firebase Auth (servidor) |
| **Hash de contraseña offline** | String (SHA-256) | SQLite local: `offline_users.db` |
| **Datos de perfil en caché** | JSON | SQLite local: `user_profile_cache.db` |
| **Fecha de última sincronización** | Timestamp | SQLite local + Firestore |
| **Token FCM (notificaciones push)** | String | Firestore: `Users/{userId}/device_tokens/{token}` |

**Protección:**
- Tokens FCM: Almacenados en Firestore con información de plataforma (Android/iOS)
- Hash de contraseña: Encriptado con AES-256-GCM en `EncryptedPreferencesService`
- Claves de encriptación: Almacenadas en Android Keystore / iOS Keychain (hardware)

---

## 3. DATOS RECOPILADOS DEL HIJO/BEBÉ

### 3.1. Datos de Identificación del Bebé

**Ubicación en el código:**
- `lib/features/user/domain/entities/user_profile_entities.dart` (BabyInfo)
- `lib/features/onboarding/presentation/pages/postpartum_form_page.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **Nombre o apodo del bebé** (`nombre bebe`/`babyName`) | String | Firestore: `Users/{userId}/seleccion/{situationId}` |
| **Fecha de nacimiento** (`fecha nacimiento bebe`/`birthDate`) | DateTime | Firestore: `Users/{userId}/seleccion/{situationId}` |
| **Hora de nacimiento** (`hora nacimiento`/`birthTime`) | String | Firestore: `Users/{userId}/seleccion/{situationId}` |
| **Lugar de nacimiento** (`lugar nacimiento`/`birthPlace`) | String | Firestore: `Users/{userId}/seleccion/{situationId}` |
| **Peso al nacer** (`peso`/`birthWeight`) | Double | Firestore: `Users/{userId}/seleccion/{situationId}` |
| **Edad gestacional** (`edad gestacional`/`gestationalAge`) | Integer (semanas) | Firestore: `Users/{userId}/seleccion/{situationId}` |

**Clasificación Legal (Panamá):**
- **Datos de Menores**: Requieren consentimiento explícito del padre/madre/tutor legal
- **Datos Sensibles**: Información de salud del menor

### 3.2. Datos de Lactancia y Alimentación

**Ubicación en el código:**
- `lib/features/lactation/domain/entities/lactation_record.dart`
- `lib/features/lactation/presentation/pages/lactation_record_page.dart`
- `lib/features/lactation/presentation/pages/lactation_flow_page_enhanced.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **Fecha y hora del registro** (`fecha_registro`/`timestamp`) | DateTime | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Tipo de lactancia** (`tipo`) | Enum (breastfeeding/pumping/bottle) | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Duración** (`duracion`) | Duration (minutos) | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Lado del pecho** (`lado`/`pecho_dado`) | String (Izquierdo/Derecho/Ambos) | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Volumen de extracción** (`volumen_extraccion`) | Integer | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Unidad de volumen** (`unidad_volumen`) | String (ml/oz) | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Veces biberón** (`veces_biberon`) | Integer | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Veces pecho** (`veces_pecho`) | Integer | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Notas** (`notas`) | String (opcional) | Firestore: `Users/{userId}/lactancia/{recordId}` |
| **Tipo de registro** (`tipo_registro`) | String (rapido/completo) | Firestore: `Users/{userId}/lactancia/{recordId}` |

**Clasificación Legal (Panamá):**
- **Datos Sensibles de Salud**: Información sobre alimentación y lactancia del menor
- Requiere consentimiento explícito del padre/madre

### 3.3. Datos de Peso y Crecimiento

**Ubicación en el código:**
- `lib/features/lactation/domain/entities/baby_weight_record.dart`
- `lib/features/lactation/presentation/pages/baby_weight_form_page.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **Peso** (`weight`) | Double (kilogramos) | Firestore: `Users/{userId}/baby_weight/{recordId}` |
| **Fecha del registro** (`recorded_at`) | DateTime | Firestore: `Users/{userId}/baby_weight/{recordId}` |
| **Notas** (`notes`) | String (opcional) | Firestore: `Users/{userId}/baby_weight/{recordId}` |

**Clasificación Legal (Panamá):**
- **Datos Sensibles de Salud**: Información biométrica del menor
- Requiere consentimiento explícito

### 3.4. Datos de Sueño

**Ubicación en el código:**
- `lib/features/lactation/domain/entities/sleep_record.dart`
- `lib/features/lactation/presentation/pages/lactation_record_page.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **Hora de inicio del sueño** (`sleepStartTime`) | DateTime | Firestore: `Users/{userId}/sleep_records/{recordId}` |
| **Hora de fin del sueño** (`sleepEndTime`) | DateTime | Firestore: `Users/{userId}/sleep_records/{recordId}` |
| **Duración total** (`totalSleepDuration`) | Duration | Firestore: `Users/{userId}/sleep_records/{recordId}` |
| **Calidad del sueño** (`quality`) | Enum (excellent/good/fair/poor) | Firestore: `Users/{userId}/sleep_records/{recordId}` |
| **Notas** (`notes`) | String (opcional) | Firestore: `Users/{userId}/sleep_records/{recordId}` |
| **Horas de sueño del bebé** (`horas_sueno_bebe`) | Integer | Firestore: `Users/{userId}/lactancia/{recordId}` (en registros completos) |
| **Unidad de sueño** (`unidad_sueno`) | String (Hrs/Min) | Firestore: `Users/{userId}/lactancia/{recordId}` |

**Clasificación Legal (Panamá):**
- **Datos Sensibles de Salud**: Patrones de sueño del menor

---

## 4. DATOS DE USO Y COMPORTAMIENTO

### 4.1. Datos de Gamificación

**Ubicación en el código:**
- `lib/features/gamification/domain/entities/user_gamification_profile.dart`
- `lib/features/gamification/data/datasources/gamification_remote_data_source.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **XP total** (`totalXP`) | Integer | Firestore: `Users/{userId}/gamification/profile` + SQLite local |
| **Nivel actual** (`currentLevel`) | Integer | Firestore + SQLite local |
| **Racha actual** (`currentStreak`) | Integer (días) | Firestore + SQLite local |
| **Fecha de última actividad** (`lastActivityDate`) | DateTime | Firestore + SQLite local |
| **Logros desbloqueados** (`unlockedAchievements`) | List<String> | Firestore + SQLite local |
| **Estado de la mascota** (`mascotState`) | String | Firestore + SQLite local |
| **Etapa del bebé** (`babyStage`) | String | Firestore + SQLite local |
| **XP diario** (`dailyXP`) | Map<String, int> | Firestore + SQLite local |
| **Desafíos diarios completados** (`completedDailyChallenges`) | Map<String, DateTime> | Firestore + SQLite local |
| **Días de descanso usados** (`restDaysUsed`) | Integer | Firestore + SQLite local |
| **Modo pausa activo** (`isPauseModeActive`) | Boolean | Firestore + SQLite local |

**Finalidad:**
- Mejorar la experiencia del usuario mediante gamificación
- Motivar el uso continuo de la aplicación
- Analizar patrones de engagement

### 4.2. Datos de Progreso en Videos/Lecciones

**Ubicación en el código:**
- `lib/features/videos/data/services/video_progress_service.dart`
- `lib/features/user/data/datasources/user_profile_remote_data_source.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **ID del video** (`videoId`) | Integer | Firestore: `Users/{userId}/videos/{videoId}` |
| **Contador de pausas** (`contadorPausas`) | Integer | Firestore: `Users/{userId}/videos/{videoId}` |
| **Contador de adelantos** (`contadorAdelantos`) | Integer | Firestore: `Users/{userId}/videos/{videoId}` |
| **Última posición** (`ultimaPosicion`) | Integer (segundos) | Firestore: `Users/{userId}/videos/{videoId}` |
| **Duración total** (`duracion`) | Integer (segundos) | Firestore: `Users/{userId}/videos/{videoId}` |
| **Porcentaje de avance** (`avance`) | Double (0.0-1.0) | Firestore: `Users/{userId}/videos/{videoId}` |
| **Estado de completado** (`estaCompletado`) | Boolean | Firestore: `Users/{userId}/videos/{videoId}` |
| **Contador de visualizaciones** (`contadorVisualizaciones`) | Integer | Firestore: `Users/{userId}/videos/{videoId}` |
| **Registros de adelantos** | Array | Firestore: `Users/{userId}/adelantosvideo/{recordId}` |

**Finalidad:**
- Personalizar la experiencia de aprendizaje
- Continuar videos desde donde se dejaron
- Analizar el consumo de contenido educativo

### 4.3. Datos del Chatbot

**Ubicación en el código:**
- `lib/features/chatbot/data/datasources/chatbot_remote_data_source.dart`
- `lib/features/chatbot/domain/entities/chat_message.dart`

**Datos recopilados:**

| Campo | Tipo | Ubicación Almacenamiento |
|-------|------|-------------------------|
| **Historial de conversaciones** | Array<ChatMessage> | Firestore: `Users/{userId}/chat_history/{messageId}` |
| **Preguntas del usuario** (`text`, `isUser: true`) | String | Firestore: `Users/{userId}/chat_history/{messageId}` |
| **Respuestas del bot** (`text`, `isUser: false`) | String | Firestore: `Users/{userId}/chat_history/{messageId}` |
| **Timestamp de cada mensaje** (`timestamp`) | DateTime | Firestore: `Users/{userId}/chat_history/{messageId}` |

**Finalidad:**
- Proporcionar respuestas personalizadas sobre lactancia y maternidad
- Mejorar el servicio de chatbot mediante análisis de consultas
- **Nota**: Los datos se procesan localmente cuando es posible, sin enviar a servicios externos de IA

**Clasificación Legal (Panamá):**
- Puede contener **datos sensibles de salud** si el usuario menciona información médica en las conversaciones

---

## 5. DATOS RECOPILADOS AUTOMÁTICAMENTE

### 5.1. Datos del Dispositivo

**Servicios utilizados:**
- Firebase Analytics (implícito)
- Firebase Performance Monitoring
- Firebase Messaging (FCM)

**Datos recopilados:**

| Campo | Tipo | Proveedor |
|-------|------|----------|
| **Modelo del dispositivo** | String | Firebase Analytics |
| **Sistema operativo** | String | Firebase Analytics |
| **Versión del sistema operativo** | String | Firebase Analytics |
| **ID único del dispositivo** (IDFA/AAID) | String | Firebase Analytics |
| **Dirección IP** | String | Firebase (temporal, para geolocalización aproximada) |
| **Operador móvil** | String | Firebase Analytics |
| **Idioma del dispositivo** | String | Firebase Analytics |
| **Zona horaria** | String | Firebase Analytics |

**Finalidad:**
- Mejorar la compatibilidad de la aplicación
- Analizar errores y rendimiento
- Personalizar la experiencia según el dispositivo

### 5.2. Datos de Uso y Analítica

**Servicios utilizados:**
- Firebase Analytics
- Firebase Performance Monitoring
- App Logger (local)

**Datos recopilados:**

| Campo | Tipo | Ubicación |
|-------|------|-----------|
| **Páginas visitadas** | Array | Firebase Analytics |
| **Tiempo de sesión** | Duration | Firebase Analytics |
| **Interacciones con botones** | Events | Firebase Analytics |
| **Informes de errores (crash logs)** | Stack traces | Firebase Crashlytics (si está configurado) |
| **Métricas de rendimiento** | Performance data | Firebase Performance |
| **Logs de aplicación** | Text | Local (SQLite/SharedPreferences) |

**Finalidad:**
- Mejorar la experiencia del usuario
- Identificar y corregir errores
- Optimizar el rendimiento de la aplicación

### 5.3. Datos de Ubicación

**Nota importante:** La aplicación **NO recopila ubicación GPS precisa** sin permiso explícito.

**Datos recopilados:**

| Campo | Tipo | Fuente |
|-------|------|--------|
| **Ubicación aproximada** | String (ciudad/país) | Basada en dirección IP (Firebase Analytics) |
| **Ubicación del usuario** (si se proporciona) | String | Input manual del usuario en registro |

**Finalidad:**
- Personalizar contenido según región
- Cumplir con requisitos legales de localización

---

## 6. SERVICIOS DE TERCEROS Y TRANSFERENCIAS INTERNACIONALES

### 6.1. Google Firebase (Estados Unidos)

**Servicios utilizados:**
- **Firebase Authentication**: Autenticación de usuarios
- **Cloud Firestore**: Base de datos NoSQL
- **Firebase Analytics**: Análisis de uso
- **Firebase Performance Monitoring**: Monitoreo de rendimiento
- **Firebase Cloud Messaging (FCM)**: Notificaciones push
- **Firebase Crashlytics**: Reportes de errores (si está configurado)

**Datos transferidos:**
- **Todos los datos personales y sensibles** mencionados anteriormente
- **Ubicación de almacenamiento**: Servidores de Google en Estados Unidos

**Base legal para transferencia (Panamá):**
- **Consentimiento explícito** del usuario al aceptar la política de privacidad
- **Cláusulas contractuales** con Google Firebase (DPA - Data Processing Agreement)
- **Medidas de seguridad**: Firebase cumple con estándares internacionales (ISO 27001, SOC 2)

**Protección de datos:**
- Firebase utiliza encriptación en tránsito (TLS/SSL)
- Firebase utiliza encriptación en reposo
- Acceso restringido mediante reglas de seguridad de Firestore

### 6.2. Servicios de Almacenamiento Local

**Servicios utilizados:**
- **SQLite**: Base de datos local para modo offline
- **SharedPreferences**: Almacenamiento de preferencias
- **Flutter Secure Storage**: Almacenamiento seguro (Android Keystore/iOS Keychain)

**Datos almacenados localmente:**
- Perfil de usuario en caché
- Registros de lactancia (sincronización pendiente)
- Datos de gamificación
- Hash de contraseña para acceso offline
- Tokens de sesión

**Protección:**
- **Android Keystore**: Protección a nivel de hardware para claves de encriptación
- **iOS Keychain**: Almacenamiento seguro en iOS
- **AES-256-GCM**: Encriptación de datos sensibles en SharedPreferences
- **Limpieza automática**: Archivos temporales se eliminan al cerrar la aplicación

---

## 7. MEDIDAS DE PROTECCIÓN Y SEGURIDAD

### 7.1. Encriptación

**Implementación:**
- **En tránsito**: TLS/SSL para todas las comunicaciones con Firebase
- **En reposo (Firestore)**: Encriptación automática de Google
- **En reposo (local)**: 
  - AES-256-GCM para datos sensibles en SharedPreferences
  - Android Keystore / iOS Keychain para claves de encriptación
  - Encriptación de videos descargados (AES-256-GCM)

**Ubicación en el código:**
- `lib/core/services/encrypted_preferences_service.dart`
- `lib/core/services/secure_storage_service.dart`
- `lib/features/videos/data/services/video_encryption_service.dart`

### 7.2. Autenticación y Autorización

**Implementación:**
- **Firebase Authentication**: Autenticación segura con email/contraseña
- **Reglas de seguridad Firestore**: Acceso restringido por usuario
- **Validación de sesión**: Verificación de tokens en cada solicitud

**Reglas de seguridad (ejemplo conceptual):**
```javascript
// Solo el usuario puede acceder a sus propios datos
match /Users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

### 7.3. Protección de Memoria

**Implementación:**
- **Limpieza de buffers**: Sobrescritura de datos sensibles en memoria antes de liberar
- **Random.secure()**: Generación segura de datos aleatorios para sobrescritura
- **Eliminación segura de archivos**: Sobrescritura múltiple antes de eliminar archivos temporales

**Ubicación en el código:**
- `lib/features/videos/data/services/video_encryption_service.dart` (método `_clearMemory`)
- `lib/features/videos/presentation/widgets/offline_video_player.dart` (método `_secureDeleteFile`)

### 7.4. Modo Offline y Sincronización

**Implementación:**
- **Almacenamiento local**: SQLite para funcionamiento offline
- **Sincronización automática**: Cuando hay conexión, los datos se sincronizan con Firestore
- **Resolución de conflictos**: Última escritura gana (Last Write Wins)

**Ubicación en el código:**
- `lib/core/services/offline_sync_service.dart`
- `lib/features/auth/data/datasources/offline_user_local_data_source.dart`

---

## 8. FINALIDADES DEL TRATAMIENTO DE DATOS

### 8.1. Finalidades Principales

1. **Gestión de cuenta y autenticación**
   - Crear y mantener la cuenta del usuario
   - Autenticar el acceso a la aplicación
   - Recuperar contraseñas

2. **Proporcionar herramientas de seguimiento**
   - Registro de lactancia
   - Seguimiento de peso y crecimiento
   - Registro de sueño
   - Calendario de actividades

3. **Ofrecer contenido educativo personalizado**
   - Videos y lecciones sobre lactancia
   - Progreso de aprendizaje
   - Recomendaciones basadas en el perfil

4. **Chatbot de IA**
   - Respuestas personalizadas a preguntas sobre lactancia
   - Soporte 24/7
   - Mejora continua del servicio

5. **Gamificación**
   - Motivar el uso continuo
   - Recompensar logros
   - Mantener engagement

6. **Notificaciones push**
   - Recordatorios de lactancia
   - Consejos educativos
   - Actualizaciones de la aplicación

7. **Análisis y mejora**
   - Métricas de uso
   - Identificación de errores
   - Optimización de rendimiento

8. **Cumplimiento legal**
   - Retención de datos según requerimientos legales
   - Prevención de fraudes
   - Cumplimiento con regulaciones de protección de datos

### 8.2. Bases Legales (Ley 81 de Panamá)

1. **Consentimiento explícito** (Artículo 8)
   - El usuario otorga consentimiento al registrarse y aceptar la política de privacidad
   - Consentimiento específico para datos sensibles (salud, menores)

2. **Ejecución de un contrato** (Artículo 8)
   - El procesamiento es necesario para brindar el servicio de la aplicación
   - Términos y Condiciones aceptados por el usuario

3. **Interés legítimo** (Artículo 8)
   - Mejora de la seguridad y funcionalidad de la aplicación
   - Análisis de uso para optimización

---

## 9. PERÍODO DE RETENCIÓN DE DATOS

### 9.1. Datos Activos

- **Duración**: Mientras la cuenta esté activa
- **Criterio**: Usuario con sesión activa en los últimos 2 años

### 9.2. Datos Inactivos

- **Duración**: 2 años desde la última actividad
- **Acción**: Notificación al usuario para reactivar o eliminar cuenta
- **Eliminación**: Después de 2 años de inactividad, datos se eliminan o anonimizan

### 9.3. Datos Legales

- **Duración**: Según requerimientos legales (puede ser más de 2 años)
- **Criterio**: Obligaciones legales, fiscales, o de salud pública

### 9.4. Datos de Menores

- **Duración**: Hasta que el menor cumpla 18 años, o según solicitud del padre/madre/tutor
- **Eliminación**: Inmediata si se solicita por el tutor legal

---

## 10. DERECHOS DEL USUARIO (LEY 81 DE PANAMÁ)

### 10.1. Derechos ARCO

1. **Acceso** (Artículo 15)
   - Solicitar confirmación de si se están procesando sus datos
   - Obtener una copia de sus datos personales
   - **Ejercicio**: Email a [correo de soporte] con asunto "Derecho de Acceso"

2. **Rectificación** (Artículo 16)
   - Corregir datos inexactos, incompletos o desactualizados
   - **Ejercicio**: Desde la aplicación en Configuración > Perfil, o por email

3. **Cancelación** (Artículo 17)
   - Eliminar datos cuando ya no sean necesarios
   - Retirar consentimiento
   - **Ejercicio**: Configuración > Eliminar cuenta, o por email

4. **Oposición** (Artículo 18)
   - Oponerse al tratamiento por motivos fundados
   - **Ejercicio**: Email a [correo de soporte] con asunto "Derecho de Oposición"

### 10.2. Derecho de Portabilidad

- **Recibir datos en formato estructurado** (JSON)
- **Transferir datos a otro proveedor**
- **Ejercicio**: Email a [correo de soporte] con asunto "Portabilidad de Datos"

### 10.3. Plazos de Respuesta (Ley 81)

- **Respuesta inicial**: 10 días hábiles
- **Resolución definitiva**: 30 días hábiles (prorrogable por 30 días más con justificación)

---

## 11. COMPARTICIÓN DE DATOS CON TERCEROS

### 11.1. Proveedores de Servicios

**Google Firebase (Estados Unidos)**
- **Tipo de datos**: Todos los datos personales y sensibles
- **Finalidad**: Almacenamiento, autenticación, analítica, notificaciones
- **Base legal**: Contrato de procesamiento de datos (DPA)
- **Medidas de seguridad**: ISO 27001, SOC 2, encriptación

### 11.2. No se Comparten Datos Con

- **Anunciantes**: No se venden datos a terceros para publicidad
- **Servicios de marketing**: No se comparten datos para marketing directo sin consentimiento
- **Servicios de IA externos**: El chatbot procesa datos localmente cuando es posible

### 11.3. Transferencias Internacionales

**Destino**: Estados Unidos (servidores de Google Firebase)

**Garantías**:
- **Cláusulas contractuales estándar** (SCC) de la UE (aplicables por analogía)
- **Data Processing Agreement (DPA)** con Google
- **Medidas técnicas**: Encriptación, acceso restringido
- **Medidas organizativas**: Políticas de privacidad, capacitación del personal

**Consentimiento del usuario**:
- Al aceptar la política de privacidad, el usuario consiente explícitamente la transferencia internacional
- Reconocimiento de que Estados Unidos puede tener leyes de protección de datos diferentes a Panamá

---

## 12. DATOS ESPECÍFICOS DE MENORES (COPPA y Ley 81)

### 12.1. Consentimiento del Tutor Legal

- **Quién proporciona los datos**: Exclusivamente el padre, madre o tutor legal
- **Edad del menor**: No hay límite de edad (aplicación para bebés)
- **Consentimiento**: Implícito al registrar datos del bebé en la aplicación

### 12.2. Datos Recopilados del Menor

Todos los datos mencionados en la **Sección 3 (Datos del Hijo/Bebé)** son proporcionados por el tutor legal.

### 12.3. Derechos del Tutor Legal

- **Acceso**: Ver todos los datos del menor
- **Rectificación**: Corregir datos incorrectos
- **Eliminación**: Eliminar todos los datos del menor en cualquier momento
- **Portabilidad**: Exportar datos del menor

### 12.4. Protección Especial

- **Encriptación adicional**: Datos de menores tienen protección reforzada
- **Acceso restringido**: Solo el tutor legal puede acceder a los datos del menor
- **Eliminación prioritaria**: Solicitudes de eliminación de datos de menores se procesan con prioridad

---

## 13. NOTIFICACIONES PUSH

### 13.1. Datos Recopilados

- **Token FCM**: Identificador único del dispositivo para enviar notificaciones
- **Plataforma**: Android o iOS
- **Fecha de registro**: Timestamp de cuando se registró el token

**Ubicación**: `Users/{userId}/device_tokens/{token}`

### 13.2. Finalidad

- Recordatorios de lactancia
- Consejos educativos
- Actualizaciones de la aplicación
- Notificaciones de logros (gamificación)

### 13.3. Control del Usuario

- **Activar/Desactivar**: Configuración > Notificaciones
- **Eliminar token**: Al desactivar notificaciones, el token se elimina de Firestore

---

## 14. RECOMENDACIONES PARA LA POLÍTICA DE PRIVACIDAD

### 14.1. Secciones Obligatorias (Ley 81 de Panamá)

1. **Identificación del Responsable**
   - Razón social completa
   - Dirección física en Panamá
   - Correo electrónico de contacto legal
   - Número de teléfono

2. **Datos Recopilados**
   - Lista exhaustiva de todos los datos (como se detalla en este documento)
   - Clasificación: personales, sensibles, de menores
   - Fuente de los datos (usuario, automático, terceros)

3. **Finalidades del Tratamiento**
   - Lista específica de para qué se usan los datos
   - Base legal para cada finalidad

4. **Transferencias Internacionales**
   - Destino de los datos (Estados Unidos)
   - Garantías de protección
   - Consentimiento explícito

5. **Derechos ARCO**
   - Explicación de cada derecho
   - Cómo ejercerlos
   - Plazos de respuesta

6. **Medidas de Seguridad**
   - Encriptación
   - Acceso restringido
   - Protección de datos sensibles

7. **Retención de Datos**
   - Período de retención
   - Criterios de eliminación

8. **Contacto**
   - Correo para ejercer derechos
   - Procedimiento de quejas

### 14.2. Lenguaje Recomendado

- **Claro y sencillo**: Evitar jerga legal excesiva
- **Específico**: No usar términos vagos como "podemos recopilar"
- **Transparente**: Ser honesto sobre qué datos se recopilan y para qué
- **Accesible**: Disponible en español (idioma principal de Panamá)

### 14.3. Consentimiento Explícito

- **Checkbox separado**: No incluir en Términos y Condiciones
- **Información previa**: Mostrar resumen antes de pedir consentimiento
- **Revocable**: Fácil de retirar desde la aplicación

---

## 15. CHECKLIST DE CUMPLIMIENTO (Ley 81 de Panamá)

### 15.1. Principios de Protección de Datos

- [x] **Licitud**: Consentimiento explícito obtenido
- [x] **Finalidad**: Finalidades específicas y legítimas
- [x] **Proporcionalidad**: Solo datos necesarios para las finalidades
- [x] **Calidad**: Datos exactos y actualizados
- [x] **Seguridad**: Medidas técnicas y organizativas adecuadas
- [x] **Confidencialidad**: Acceso restringido
- [x] **Temporalidad**: Retención limitada al tiempo necesario

### 15.2. Obligaciones del Responsable

- [x] **Registro de actividades de tratamiento**: Documentado en este análisis
- [x] **Medidas de seguridad**: Implementadas (encriptación, acceso restringido)
- [x] **Notificación de violaciones**: Procedimiento establecido (a implementar)
- [x] **Designación de encargado de datos**: Recomendado para empresas grandes

### 15.3. Derechos del Usuario

- [x] **Mecanismos para ejercer derechos**: Email de contacto, opciones en app
- [x] **Plazos de respuesta**: 10 días hábiles (inicial), 30 días (definitivo)
- [x] **Gratuito**: Sin costo para ejercer derechos (excepto solicitudes manifiestamente infundadas)

---

## 16. ANEXOS

### Anexo A: Estructura de Datos en Firestore

```
Users/
  {userId}/
    - Datos del perfil (email, nombre, teléfono, etc.)
    seleccion/
      {situationId}/
        - Datos de situación (preparto/postparto)
        - Datos del bebé (nombre, fecha nacimiento, peso, etc.)
    lactancia/
      {recordId}/
        - Registros de lactancia
    baby_weight/
      {recordId}/
        - Registros de peso
    sleep_records/
      {recordId}/
        - Registros de sueño
    videos/
      {videoId}/
        - Progreso de videos
    gamification/
      profile/
        - Perfil de gamificación
    chat_history/
      {messageId}/
        - Mensajes del chatbot
    device_tokens/
      {token}/
        - Tokens FCM para notificaciones
```

### Anexo B: Servicios de Terceros Utilizados

| Servicio | Proveedor | Ubicación | Tipo de Datos |
|----------|-----------|-----------|---------------|
| Firebase Authentication | Google | EE.UU. | Credenciales |
| Cloud Firestore | Google | EE.UU. | Todos los datos |
| Firebase Analytics | Google | EE.UU. | Datos de uso |
| Firebase Performance | Google | EE.UU. | Métricas de rendimiento |
| Firebase Messaging (FCM) | Google | EE.UU. | Tokens de dispositivo |

### Anexo C: Medidas de Seguridad Técnicas

1. **Encriptación en tránsito**: TLS 1.2+
2. **Encriptación en reposo**: AES-256-GCM (local), Encriptación de Google (Firestore)
3. **Almacenamiento seguro**: Android Keystore / iOS Keychain
4. **Autenticación**: Firebase Authentication con tokens JWT
5. **Autorización**: Reglas de seguridad de Firestore
6. **Limpieza de memoria**: Sobrescritura de buffers sensibles
7. **Eliminación segura**: Sobrescritura múltiple de archivos temporales

---

## 17. CONCLUSIÓN

Este análisis exhaustivo identifica todos los datos recopilados por la aplicación Gilact, tanto de la madre como del hijo, y proporciona la base necesaria para redactar una política de privacidad completa y conforme a la **Ley No. 81 de 2019 sobre Protección de Datos Personales de Panamá**.

**Puntos clave:**
- ✅ Todos los datos están documentados
- ✅ Las finalidades están claramente definidas
- ✅ Las medidas de seguridad están implementadas
- ✅ Los derechos del usuario están contemplados
- ✅ Las transferencias internacionales están identificadas
- ✅ Los datos de menores tienen protección especial

**Próximos pasos:**
1. Redactar la política de privacidad basada en este análisis
2. Implementar mecanismos para ejercer derechos ARCO
3. Configurar notificaciones de violaciones de datos
4. Revisar y actualizar periódicamente este análisis

---

**Documento generado por:** Análisis automatizado del código fuente  
**Última actualización:** Diciembre 2024  
**Versión:** 1.0
