# 🌍 Guía de Traducciones - Easy Localization

## 📋 Resumen

La aplicación ahora usa `easy_localization` para manejar todos los textos en múltiples idiomas. El cambio de idioma se aplica **instantáneamente** en toda la aplicación sin necesidad de reiniciar.

## 🚀 Cómo Funciona

### 1. Archivos de Traducción

Los archivos de traducción están en `assets/translations/`:
- `es.json` - Español
- `en.json` - Inglés

### 2. Estructura de Claves

Las claves están organizadas por secciones:
```json
{
  "navigation": {
    "home": "Inicio",
    "companion": "Compañera",
    ...
  },
  "profile": {
    "title": "Perfil",
    "editProfile": "Editar Perfil",
    ...
  }
}
```

### 3. Uso en el Código

Para usar una traducción, simplemente agrega `.tr()` al final de la clave:

```dart
// Antes
Text('Perfil')

// Después
Text('profile.title'.tr())
```

### 4. Cambio de Idioma

El cambio de idioma se hace automáticamente cuando el usuario selecciona un idioma en la configuración:

```dart
await context.setLocale(Locale('en')); // Cambia a inglés
await context.setLocale(Locale('es')); // Cambia a español
```

## 📝 Cómo Agregar Nuevas Traducciones

### Paso 1: Agregar la Clave en los Archivos JSON

**En `assets/translations/es.json`:**
```json
{
  "nuevaSeccion": {
    "nuevaClave": "Texto en español"
  }
}
```

**En `assets/translations/en.json`:**
```json
{
  "nuevaSeccion": {
    "nuevaClave": "Text in English"
  }
}
```

### Paso 2: Usar en el Código

```dart
Text('nuevaSeccion.nuevaClave'.tr())
```

### Paso 3: Parámetros (Opcional)

Si necesitas pasar parámetros:

**En JSON:**
```json
{
  "messages": {
    "welcome": "Bienvenido {name}",
    "@welcome": {
      "placeholders": {
        "name": {
          "type": "String"
        }
      }
    }
  }
}
```

**En el código:**
```dart
Text('messages.welcome'.tr(namedArgs: {'name': 'Juan'}))
```

## 🔧 Secciones Actuales

### Navigation
- `navigation.home` - "Inicio" / "Home"
- `navigation.companion` - "Compañera" / "Companion"
- `navigation.health` - "Salud" / "Health"
- `navigation.profile` - "Perfil" / "Profile"
- `navigation.lessons` - "Lecciones" / "Lessons"
- `navigation.tips` - "Tips" / "Tips"
- `navigation.history` - "Historial" / "History"

### Profile
- `profile.title` - "Perfil" / "Profile"
- `profile.editProfile` - "Editar Perfil" / "Edit Profile"
- `profile.name` - "Nombre" / "Name"
- `profile.email` - "Email" / "Email"
- `profile.motherName` - "Nombre de la Madre" / "Mother's Name"
- Y más...

### Settings
- `settings.title` - "Configuración de la Aplicación" / "Application Settings"
- `settings.sound` - "Sonido" / "Sound"
- `settings.vibration` - "Vibración" / "Vibration"
- `settings.autoSave` - "Guardado Automático" / "Auto Save"
- `settings.language` - "Idioma" / "Language"
- Y más...

### Common
- `common.save` - "Guardar" / "Save"
- `common.cancel` - "Cancelar" / "Cancel"
- `common.delete` - "Eliminar" / "Delete"
- `common.edit` - "Editar" / "Edit"
- Y más...

## 📍 Archivos que Necesitan Actualización

Para completar la traducción de toda la app, necesitas actualizar estos archivos:

### Prioridad Alta:
1. ✅ `lib/features/settings/presentation/pages/profile_settings_page.dart` - **COMPLETADO**
2. ✅ `lib/features/settings/presentation/widgets/app_settings_card_widget.dart` - **COMPLETADO**
3. ✅ `lib/features/navigation/presentation/widgets/modern_bottom_navigation_bar.dart` - **COMPLETADO**
4. ⏳ `lib/features/navigation/presentation/pages/home_page.dart` - Pendiente
5. ⏳ `lib/features/navigation/presentation/pages/companion_page.dart` - Pendiente
6. ⏳ `lib/features/navigation/presentation/pages/health_page.dart` - Pendiente
7. ⏳ `lib/features/lactation/presentation/pages/lactation_record_page.dart` - Pendiente
8. ⏳ `lib/features/lessons/presentation/pages/lessons_page.dart` - Pendiente
9. ⏳ `lib/features/tips/presentation/pages/tips_page.dart` - Pendiente

### Prioridad Media:
- Formularios de lactación
- Formularios de peso del bebé
- Formularios de sueño
- Diálogos y mensajes

## 🎯 Ejemplo Completo

### Antes:
```dart
Column(
  children: [
    Text('Perfil'),
    ElevatedButton(
      onPressed: () {},
      child: Text('Guardar'),
    ),
  ],
)
```

### Después:
```dart
import 'package:easy_localization/easy_localization.dart';

Column(
  children: [
    Text('profile.title'.tr()),
    ElevatedButton(
      onPressed: () {},
      child: Text('common.save'.tr()),
    ),
  ],
)
```

## ⚠️ Notas Importantes

1. **Siempre agrega el import:**
   ```dart
   import 'package:easy_localization/easy_localization.dart';
   ```

2. **Usa claves descriptivas:**
   - ✅ `profile.editProfile` 
   - ❌ `edit`

3. **Organiza por secciones:**
   - `navigation.*` - Navegación
   - `profile.*` - Perfil
   - `settings.*` - Configuración
   - `common.*` - Textos comunes

4. **Mantén consistencia:**
   - Si ya existe una clave similar, úsala
   - No dupliques traducciones

5. **Prueba ambos idiomas:**
   - Cambia el idioma en la configuración
   - Verifica que todos los textos se traduzcan correctamente

## 🔄 Flujo de Cambio de Idioma

1. Usuario selecciona idioma en configuración
2. Se guarda en `SharedPreferences` mediante `SettingsBloc`
3. Se llama `context.setLocale(Locale('en'))`
4. `EasyLocalization` actualiza automáticamente todos los `.tr()`
5. La UI se reconstruye con el nuevo idioma

## 📚 Recursos

- [Documentación de easy_localization](https://pub.dev/packages/easy_localization)
- Archivos de traducción: `assets/translations/`
- Servicio de localización: `lib/core/services/localization_service.dart`

