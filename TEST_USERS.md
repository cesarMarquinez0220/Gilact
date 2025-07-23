# 👥 Usuarios de Prueba - Gilact

Este archivo contiene información sobre los usuarios de prueba creados para la aplicación Gilact.

## 🔑 Credenciales de Acceso

### Usuario Administrador
- **Email:** `admin@test.com`
- **Contraseña:** `123456`
- **Nombre:** María García
- **Ubicación:** San José, Costa Rica

### Usuario Demo
- **Email:** `demo@gilact.com`
- **Contraseña:** `demo123`
- **Nombre:** Ana López
- **Ubicación:** Cartago, Costa Rica

### Usuario de Prueba
- **Email:** `test@example.com`
- **Contraseña:** `test123`
- **Nombre:** Carmen Rodríguez
- **Ubicación:** Alajuela, Costa Rica

## 🚀 Cómo Crear los Usuarios

### 🌐 Con Conexión a Internet:
1. Ve a la pantalla de registro
2. Toca el botón naranja "TEST" en la esquina superior derecha
3. Los usuarios se crearán automáticamente en Firebase

### 📱 Sin Conexión a Internet (Modo Offline):
1. Ve a la pantalla de registro
2. Toca el botón naranja "TEST" 
3. Se mostrará un diálogo con las credenciales
4. Los usuarios están hardcodeados en la app para pruebas offline

## 🔌 Modo Offline

**¡NUEVO!** La aplicación ahora funciona sin conexión a internet para pruebas:

### ✅ Funcionalidades Offline:
- **Login** con usuarios de prueba hardcodeados
- **Validación** de credenciales local
- **Navegación** completa de la aplicación
- **Mensajes informativos** sobre el estado de conexión

### 🔄 Detección Automática:
- La app detecta automáticamente si hay conexión
- Si no hay internet, usa validación local
- Si hay conexión, usa Firebase normalmente
- Timeouts de 5 segundos para evitar esperas largas

## 📝 Estructura de Datos

Cada usuario tiene la siguiente estructura en Firestore:

```json
{
  "usuario": "nombre_usuario",
  "email": "email@ejemplo.com",
  "contrasena": "contraseña_simple",
  "nombre madre": "Nombre Completo",
  "fechaNacimiento": "1990-05-15",
  "edad": 33,
  "cedula": "1-2345-6789",
  "ubicacion": "Ciudad, País",
  "telefono": "88887777",
  "fechaRegistro": "2024-01-15T10:30:00.000Z"
}
```

## ⚠️ Importante

- **Solo para desarrollo:** Estos usuarios son únicamente para pruebas
- **Contraseñas simples:** No usar en producción
- **Eliminar en producción:** Remover el botón TEST y validación offline antes del release
- **Datos ficticios:** Toda la información personal es inventada

## 🔧 Funcionalidades a Probar

Con estos usuarios puedes probar:
- ✅ Login exitoso (online y offline)
- ✅ Validación de credenciales
- ✅ Navegación post-login
- ✅ Almacenamiento de datos de usuario
- ✅ Funcionalidades de la aplicación
- ✅ Manejo de errores de conectividad
- ✅ Modo offline completo

## 📱 Uso Rápido

### Para Pruebas Online:
```
Email: admin@test.com
Contraseña: 123456
```

### Para Pruebas Offline:
1. Desconecta el internet del dispositivo/emulador
2. Usa las mismas credenciales
3. La app funcionará en modo offline

## 🐛 Resolución de Problemas

### Error: "Unable to resolve host firestore.googleapis.com"
- **Causa:** Sin conexión a internet
- **Solución:** La app automáticamente cambia a modo offline
- **Resultado:** Login funciona con usuarios hardcodeados

### Error: "Failed to load font"
- **Causa:** Sin conexión para descargar Google Fonts
- **Solución:** La app usa fuentes del sistema como fallback
- **Resultado:** Interfaz funciona normalmente

¡Listo para probar online y offline! 🚀 