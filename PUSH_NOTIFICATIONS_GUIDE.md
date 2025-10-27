# Guía de Notificaciones Push desde Firestore

## ✅ Configuración Completada

1. ✅ `firebase_messaging` agregado al `pubspec.yaml`
2. ✅ Servicio `PushNotificationService` creado
3. ✅ Handler de background messages registrado en `main.dart`
4. ✅ Servicio inicializado en `main.dart`

## 📱 Cómo Funciona

### 1. Cuando el Usuario Inicia Sesión

- El dispositivo obtiene un **token FCM** (Firebase Cloud Messaging)
- Este token se guarda en Firestore en: `/Users/{userId}/device_tokens/{token}`
- El token permite enviar notificaciones solo a ese dispositivo

### 2. Tipo de Notificaciones que Puedes Enviar

El servicio está configurado para manejar 3 tipos:

- `lesson` - Navegar a lecciones
- `lactation_quick` - Registro rápido de lactancia
- `lactation_complete` - Registro completo de lactancia

## 🔧 Cómo Enviar Notificaciones

### Opción 1: Desde Firebase Console (Manual)

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a **Messaging** → **New Campaign** → **Firebase Notification messages**
4. Completa:
   - **Notification title**: "📚 ¡Avanza en las lecciones!"
   - **Notification text**: "No te pierdas tus lecciones del día"
5. En **Target**:
   - Selecciona "Single device" y pega el token FCM del usuario
   - O selecciona "User segment" para enviar a múltiples usuarios
6. En **Additional options** → **Custom data**:
   ```json
   {
     "type": "lesson"
   }
   ```
7. Envía la notificación

### Opción 2: Desde Cloud Functions (Automático)

Crea una función en Firestore que envíe notificaciones automáticamente:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Enviar notificación cuando se actualiza el progreso de lecciones
exports.sendLessonReminder = functions.firestore
  .document('Users/{userId}/situacion/seleccion/progreso_lecciones/{docId}')
  .onUpdate(async (change, context) => {
    const data = change.after.data();
    const userId = context.params.userId;
    
    // Obtener tokens del usuario
    const tokensSnapshot = await admin.firestore()
      .collection(`Users/${userId}/device_tokens`)
      .get();
    
    const tokens = tokensSnapshot.docs.map(doc => doc.id);
    
    if (tokens.length === 0) {
      console.log('No hay tokens para enviar');
      return null;
    }
    
    // Preparar la notificación
    const message = {
      notification: {
        title: '📚 ¡Avanza en las lecciones!',
        body: 'Tienes nuevas lecciones esperándote'
      },
      data: {
        type: 'lesson'
      },
      tokens: tokens
    };
    
    // Enviar
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`${response.successCount} notificaciones enviadas`);
    
    return null;
  });

// Enviar notificación de recordatorio de lactancia
exports.sendLactationReminder = functions.pubsub
  .schedule('every 3 hours')
  .onRun(async (context) => {
    // Obtener todos los usuarios postparto
    const usersSnapshot = await admin.firestore()
      .collection('Users')
      .where('situacion.seleccion.situationType', '==', 'postparto')
      .get();
    
    const batch = admin.messaging().batch();
    
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      
      // Obtener tokens del usuario
      const tokensSnapshot = await admin.firestore()
        .collection(`Users/${userId}/device_tokens`)
        .get();
      
      const tokens = tokensSnapshot.docs.map(doc => doc.id);
      
      if (tokens.length === 0) continue;
      
      const message = {
        notification: {
          title: '🍼 Recordatorio de Lactancia',
          body: '¿Registraste tu última sesión de lactancia?'
        },
        data: {
          type: 'lactation_quick'
        },
        tokens: tokens
      };
      
      batch.sendEachForMulticast(message);
    }
    
    return null;
  });
```

### Opción 3: Desde la App (Cliente)

Puedes crear un servicio de administración para enviar notificaciones desde la app:

```dart
// lib/features/admin/services/notification_admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Enviar notificación a un usuario específico
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String type, // 'lesson', 'lactation_quick', 'lactation_complete'
  }) async {
    // Obtener tokens del usuario
    final tokensSnapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('device_tokens')
        .get();
    
    final tokens = tokensSnapshot.docs.map((doc) => doc.id).toList();
    
    if (tokens.isEmpty) {
      print('⚠️ No hay tokens para enviar notificación');
      return;
    }
    
    // Guardar notificación pendiente en Firestore
    // Cloud Functions la enviará automáticamente
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('pending_notifications')
        .add({
      'title': title,
      'body': body,
      'type': type,
      'created_at': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }
}
```

## 🎯 Ejemplos de Uso

### Enviar Notificación de Lecciones

```dart
final adminService = NotificationAdminService();

await adminService.sendNotificationToUser(
  userId: 'userId123',
  title: '📚 ¡Avanza en las lecciones!',
  body: 'Tienes nuevas lecciones esperándote',
  type: 'lesson',
);
```

### Enviar Recordatorio de Registro Rápido de Lactancia

```dart
await adminService.sendNotificationToUser(
  userId: 'userId123',
  title: '🍼 Registro de Lactancia',
  body: '¿Registraste tu última sesión?',
  type: 'lactation_quick',
);
```

### Enviar Recordatorio de Registro Completo

```dart
await adminService.sendNotificationToUser(
  userId: 'userId123',
  title: '📝 Registro Completo de Lactancia',
  body: 'Toma el tiempo para registrar todos los detalles',
  type: 'lactation_complete',
);
```

## 📊 Estructura en Firestore

### Tokens de Dispositivos
```
Users/{userId}/device_tokens/{token}
{
  "token": "fcm_token_here",
  "platform": "android",
  "created_at": timestamp,
  "updated_at": timestamp
}
```

### Notificaciones Pendientes
```
Users/{userId}/pending_notifications/{notificationId}
{
  "title": "Notification title",
  "body": "Notification body",
  "type": "lesson",
  "created_at": timestamp,
  "sent": false
}
```

## ⚙️ Configuración Adicional

### Android
Ya está configurado en `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS (cuando agregues soporte iOS)
1. Configura los certificates en Firebase Console
2. Agrega permisos en `Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

## 🧪 Probar las Notificaciones

### Desde Firebase Console:
1. Ve a Messaging → New Campaign
2. Envía una notificación de prueba
3. Agrega data `{"type": "lesson"}`

### Verificar tokens guardados:
```dart
final userId = FirebaseAuth.instance.currentUser?.uid;
final tokensSnapshot = await FirebaseFirestore.instance
    .collection('Users')
    .doc(userId)
    .collection('device_tokens')
    .get();

print('Tokens: ${tokensSnapshot.docs.length}');
```

## 🎓 Próximos Pasos

1. **Implementar navegación**: Edita `push_notification_service.dart` para implementar las funciones `_navigateToLessons()`, etc.
2. **Crear Cloud Functions**: Para enviar notificaciones automáticamente
3. **Dashboard de administración**: Interfaz para que admins envíen notificaciones
4. **Analytics**: Seguimiento de notificaciones abiertas

---

## 📝 Notas Importantes

- Las notificaciones push requieren conexión a internet
- Los tokens cambian cuando el usuario reinstala la app
- Limpia tokens antiguos periódicamente
- Respetar configuración de "No molestar" del usuario

