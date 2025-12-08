# Guía de Certificate Pinning - Gilact

## ¿Qué es Certificate Pinning?

Certificate Pinning (fijación de certificados) es una técnica de seguridad que asocia un host con su certificado público esperado. Esto previene ataques Man-in-the-Middle (MITM) al garantizar que la aplicación solo se conecte a servidores con certificados específicos.

## ⚠️ Estado Actual: Deshabilitado Temporalmente

**Razón**: El certificate pinning estaba bloqueando las conexiones de reCAPTCHA de Firebase, causando errores de login ("Pin verification failed").

**Solución Temporal**: Se removió el `pin-set` pero se mantiene la configuración segura de dominios específicos.

**Próximos Pasos**: Para implementar certificate pinning correctamente:
1. Obtener los hashes SHA-256 exactos de los certificados actuales de Google/Firebase
2. Incluir todos los dominios necesarios (incluyendo reCAPTCHA)
3. Probar exhaustivamente antes de activar en producción

## Cómo Obtener los Hashes de Certificados

### Método 1: Usando OpenSSL (Recomendado)

```bash
# Para obtener el hash SHA-256 de un certificado
openssl s_client -connect firebase.google.com:443 -showcerts | \
  openssl x509 -pubkey -noout | \
  openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | \
  openssl enc -base64
```

### Método 2: Usando un script Python

```python
import ssl
import socket
import hashlib
import base64

def get_certificate_pin(hostname, port=443):
    """Obtiene el hash SHA-256 de un certificado"""
    context = ssl.create_default_context()
    with socket.create_connection((hostname, port)) as sock:
        with context.wrap_socket(sock, server_hostname=hostname) as ssock:
            cert = ssock.getpeercert(binary_form=True)
            pubkey = ssl.DER_cert_to_PEM_cert(cert)
            # Extraer la clave pública y calcular hash
            # (simplificado, usar OpenSSL es más confiable)
    return pin

# Ejemplo
pin = get_certificate_pin("firebase.google.com")
print(f"SHA-256 Pin: {pin}")
```

### Método 3: Herramientas Online

- **SSL Labs**: https://www.ssllabs.com/ssltest/
- **Certificate Transparency Logs**: https://crt.sh/

## Actualizar los Pins

### ¿Cuándo actualizar?

1. **Cuando Google renueve sus certificados** (típicamente cada 1-2 años)
2. **Si cambias de proveedor de servicios** (Firebase a otro)
3. **Si agregas nuevos dominios** que requieren pinning

### Pasos para actualizar:

1. Obtener los nuevos hashes usando uno de los métodos anteriores
2. Actualizar `network_security_config.xml` con los nuevos pins
3. Actualizar la fecha de expiración (`expiration`)
4. Probar la conexión en modo debug primero
5. Hacer build de release y verificar

## Configuración Actual

### Dominios con Pinning:
- `firebase.google.com`
- `firebaseapp.com`
- `googleapis.com`
- `google.com`

### Hashes Configurados:
- Google Internet Authority G2
- Google Internet Authority G3
- GlobalSign Root CA - R1 (backup)
- GlobalSign Root CA - R2 (backup)

## Consideraciones Importantes

### ⚠️ Advertencias:

1. **Expiración**: Los pins tienen una fecha de expiración. Deben actualizarse antes de que expiren.
2. **Backup Pins**: Siempre incluir múltiples pins (certificados raíz e intermedios) para evitar bloqueos si un certificado se renueva.
3. **Testing**: Probar en modo debug antes de release para evitar que la app se bloquee.
4. **Actualizaciones**: Monitorear cuando Google renueva certificados para actualizar los pins.

### ✅ Beneficios:

1. **Previene MITM**: Ataques Man-in-the-Middle no pueden interceptar conexiones
2. **Mejora MobSF Score**: Reduce warnings sobre confianza en certificados del sistema
3. **Mayor Seguridad**: Garantiza que solo te conectas a servidores legítimos

### ⚠️ Riesgos:

1. **App puede bloquearse** si los certificados cambian y no actualizas los pins
2. **Requiere mantenimiento** periódico para actualizar pins
3. **Puede causar problemas** en entornos corporativos con proxies

## Deshabilitar Pinning (Solo para Debug)

Si necesitas deshabilitar temporalmente el pinning para debugging:

```xml
<!-- Comentar el pin-set temporalmente -->
<!--
<pin-set expiration="2026-12-31">
    ...
</pin-set>
-->
```

**⚠️ IMPORTANTE**: Nunca dejar deshabilitado en producción.

## Verificación

### Verificar que funciona:

1. Construir APK de release
2. Instalar en dispositivo
3. Verificar que las conexiones a Firebase funcionan
4. Intentar interceptar con un proxy (debería fallar si el pinning funciona)

### Logs de Android:

```bash
adb logcat | grep -i "certificate\|pin\|ssl"
```

## Referencias

- [Android Network Security Config](https://developer.android.com/training/articles/security-config)
- [OWASP Certificate Pinning](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning)
- [Firebase Security](https://firebase.google.com/docs/auth/security)
