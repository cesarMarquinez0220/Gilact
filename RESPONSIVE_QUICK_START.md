# 🚀 Quick Start: Testing Responsive en Gilact

## 📋 Pasos Rápidos para Testing

### 1. Usar el ResponsiveHelper

```dart
import 'package:gilact/core/utils/responsive_helper.dart';

// En cualquier widget
Widget build(BuildContext context) {
  // Verificar tamaño de pantalla
  if (ResponsiveHelper.isSmall(context)) {
    // Código para pantallas pequeñas
  }
  
  // Obtener padding responsive
  final padding = ResponsiveHelper.getResponsivePadding(context);
  
  // Obtener tamaño de fuente responsive
  final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 16.0);
  
  return Container(
    padding: EdgeInsets.all(padding),
    child: Text(
      'Texto',
      style: TextStyle(fontSize: fontSize),
    ),
  );
}
```

### 2. Activar Debug Banner (Opcional)

En `main.dart`, envolver el MaterialApp:

```dart
import 'package:gilact/core/widgets/responsive_debug_banner.dart';

MaterialApp(
  home: ResponsiveDebugBanner(
    child: YourHomePage(),
  ),
)
```

O usar el overlay completo:

```dart
ResponsiveDebugOverlay(
  child: YourHomePage(),
)
```

### 3. Testing Rápido en Chrome

```bash
# Ejecutar en Chrome
flutter run -d chrome

# Luego en DevTools (F12):
# 1. Presionar Ctrl+Shift+M (Device Toolbar)
# 2. Seleccionar diferentes dispositivos
# 3. O crear custom sizes
```

### 4. Testing en Emuladores/Simuladores

#### Android
```bash
# Listar AVDs disponibles
flutter emulators

# Lanzar emulador específico
flutter emulators --launch <emulator-id>

# Ejecutar app
flutter run
```

#### iOS
```bash
# Listar simuladores
xcrun simctl list devices

# Ejecutar en simulador específico
flutter run -d <device-id>
```

### 5. Checklist Rápido (Top 5 Dispositivos)

- [ ] **iPhone SE** (320x568) - Más pequeño
- [ ] **iPhone 12/13** (390x844) - Estándar
- [ ] **iPhone 12/13 Pro Max** (428x926) - Más grande
- [ ] **Android Pequeño** (360x640) - Android común
- [ ] **Android Grande** (411x731) - Android grande

### 6. Problemas Comunes - Soluciones Rápidas

#### Overflow Horizontal
```dart
// ❌ Mal
Container(width: 400)

// ✅ Bien
Expanded(child: Container())
// o
Flexible(child: Container())
```

#### Texto Cortado
```dart
// ✅ Bien
Text(
  'Texto largo',
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
)
```

#### Botones Muy Pequeños
```dart
// ✅ Bien - Usar ResponsiveHelper
SizedBox(
  height: ResponsiveHelper.getResponsiveButtonHeight(context),
  child: ElevatedButton(...),
)
```

### 7. Herramientas Recomendadas

1. **Flutter DevTools** - Built-in, siempre disponible
2. **Device Preview** (opcional) - Para testing rápido
   ```yaml
   dev_dependencies:
     device_preview: ^1.0.0
   ```

### 8. Prioridades de Testing

**Alta**: iPhone SE, iPhone 12/13, Android 360x640  
**Media**: iPhone Pro Max, Android 411x731  
**Baja**: Tablets, dispositivos muy antiguos

---

## 📝 Notas

- El `ResponsiveHelper` está en `lib/core/utils/responsive_helper.dart`
- La guía completa está en `RESPONSIVE_TESTING_GUIDE.md`
- El debug banner solo funciona en modo debug (`kDebugMode`)


