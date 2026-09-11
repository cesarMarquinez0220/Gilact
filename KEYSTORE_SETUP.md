# Configuración de Keystore para Release - Gilact

## Estado Actual

✅ **Configuración completa en código:**
- `android/app/build.gradle.kts`: Configuración de signing implementada (líneas 39-77)
- `android/key.properties`: Archivo de configuración existe
- `buildTypes.release`: Configurado para usar signingConfig (línea 82)

⚠️ **Falta:**
- El archivo `android/app/upload-keystore.jks` (está en `.gitignore` por seguridad)

## ¿Por qué MobSF reporta "Missing Code Signing certificate"?

MobSF analiza el APK que le proporcionas. Si analizas un APK de **debug**, no tendrá firma de producción y MobSF reportará este warning.

**Solución**: Analizar un APK de **RELEASE** construido con el keystore.

## Crear el Keystore (Si no existe)

### Opción 1: Crear nuevo keystore

```bash
# Navegar al directorio android/app
cd android/app

# Crear el keystore
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass Guilact2025Secure! \
  -keypass Guilact2025Secure!
```

**⚠️ IMPORTANTE**: 
- Guarda el keystore en un lugar seguro
- **NUNCA** lo subas a Git (ya está en `.gitignore`)
- Si pierdes el keystore, no podrás actualizar la app en Google Play

### Opción 2: Si ya tienes un keystore

1. Copia tu archivo `.jks` a `android/app/upload-keystore.jks`
2. Verifica que `android/key.properties` tenga la configuración correcta:
   ```
   storePassword=TuPassword
   keyPassword=TuPassword
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

## Construir APK de Release

### Para APK:
```bash
flutter build apk --release
```

### Para App Bundle (recomendado para Google Play):
```bash
flutter build appbundle --release
```

El APK/AAB resultante estará firmado con tu keystore.

## Verificar que está Firmado

```bash
# Verificar firma del APK
jarsigner -verify -verbose -certs android/app/build/outputs/apk/release/app-release.apk

# O usando apksigner (Android SDK)
apksigner verify --print-certs android/app/build/outputs/apk/release/app-release.apk
```

Deberías ver información sobre el certificado de firma.

## Analizar con MobSF

1. Construir APK de release: `flutter build apk --release`
2. Subir el APK de **release** a MobSF (no el de debug)
3. MobSF no reportará "Missing Code Signing certificate"

## Ubicación de Archivos

```
android/
├── key.properties          # Configuración (en .gitignore)
└── app/
    ├── build.gradle.kts     # Configuración de signing (líneas 39-77)
    └── upload-keystore.jks  # Keystore (en .gitignore, NO subir a Git)
```

## Seguridad

### ✅ Buenas Prácticas:
- ✅ Keystore en `.gitignore` (ya configurado)
- ✅ `key.properties` en `.gitignore` (ya configurado)
- ✅ Passwords seguros
- ✅ Backup del keystore en lugar seguro

### ⚠️ Advertencias:
- **NUNCA** compartas el keystore públicamente
- **NUNCA** subas el keystore a Git
- Guarda el keystore en múltiples lugares seguros
- Si pierdes el keystore, no podrás actualizar la app

## Resumen

| Componente | Estado | Ubicación |
|------------|--------|-----------|
| Configuración build.gradle.kts | ✅ Completa | `android/app/build.gradle.kts:39-77` |
| key.properties | ✅ Existe | `android/key.properties` |
| buildTypes.release | ✅ Configurado | `android/app/build.gradle.kts:82` |
| upload-keystore.jks | ⚠️ Crear si no existe | `android/app/upload-keystore.jks` |

**Conclusión**: La configuración está completa. Solo necesitas:
1. Crear el keystore (si no existe)
2. Construir APK de release
3. Analizar el APK de release con MobSF
