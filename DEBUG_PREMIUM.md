# Guía de Debug para Verificación Premium

## 🔍 Problema: Suscripción activa no se detecta

Si tienes una suscripción activa en Google Play pero la app muestra "Inactiva", sigue estos pasos:

## 1. Verificar IDs de Productos

Los IDs en el código deben coincidir **EXACTAMENTE** con los configurados en Google Play Console:

### IDs en el código:
- `cuidatuplata_sus_mensual` (mensual)
- `cuidatuplata_sus_anual` (anual)

### Cómo verificar en Google Play Console:
1. Ve a [Google Play Console](https://play.google.com/console)
2. Selecciona tu app
3. Ve a **Monetización > Productos y suscripciones**
4. Verifica que los IDs coincidan **EXACTAMENTE** (mayúsculas/minúsculas, guiones, etc.)

## 2. Verificar Logs de la App

La app ahora tiene logging detallado. Para ver los logs:

### En Android Studio:
1. Abre Android Studio
2. Conecta tu dispositivo o inicia el emulador
3. Ejecuta la app en modo debug
4. Abre la pestaña **Logcat**
5. Filtra por: `flutter` o busca los emojis: 🔍 🛒 ✅ ❌

### Desde la terminal (Windows):
```bash
adb logcat | findstr /i "flutter"
```

### Logs importantes a buscar:
- `🔍 Iniciando verificación de compras activas...`
- `📱 Compras disponibles: true/false`
- `🔄 Restaurando compras...`
- `📦 Recibidas X compra(s) del stream`
- `🛒 Procesando compra:` (muestra el Product ID)
- `✅ Premium activado para producto:`

## 3. Verificar Tipo de Producto en Google Play

**IMPORTANTE**: Las suscripciones deben estar configuradas como **Suscripciones**, NO como productos no consumibles.

### En Google Play Console:
1. Ve a **Monetización > Productos y suscripciones**
2. Verifica que el tipo sea **"Suscripción"** (Subscription)
3. NO debe ser "Producto no consumible" (Non-consumable)

## 4. Verificar Estado de la Suscripción

En Google Play Console:
1. Ve a **Monetización > Productos y suscripciones**
2. Selecciona tu suscripción
3. Verifica que el estado sea **"Activo"** o **"Publicado"**
4. Verifica que la suscripción esté en el estado correcto (no en borrador)

## 5. Verificar Cuenta de Google

Asegúrate de que:
1. La cuenta de Google en tu dispositivo sea la misma que compró la suscripción
2. La app esté firmada con la misma cuenta de desarrollador
3. Si estás en modo prueba, verifica que tu cuenta esté en la lista de testers

## 6. Probar Verificación Manual

1. Abre la app
2. Ve a **Configuración > Versión Premium**
3. Toca **"Verificar Suscripción"**
4. Observa los logs para ver qué sucede

## 7. Posibles Problemas y Soluciones

### Problema: "Compras no están disponibles"
- **Solución**: Verifica que Google Play Services esté actualizado
- Verifica la conexión a internet

### Problema: "No se recibieron compras del stream"
- **Solución**: Los IDs pueden no coincidir
- Verifica que la suscripción esté activa en Google Play Console
- Espera unos segundos después de restaurar compras

### Problema: "Producto no reconocido como premium"
- **Solución**: Los IDs no coinciden. Verifica mayúsculas/minúsculas exactas

### Problema: "Estado: error"
- **Solución**: Revisa el mensaje de error en los logs
- Verifica que la suscripción no haya expirado
- Verifica que la cuenta de Google sea correcta

## 8. Cambiar IDs de Productos (si es necesario)

Si necesitas cambiar los IDs en el código:

1. Edita `lib/services/premium_service.dart`
2. Modifica las constantes en `PremiumProducts`:
```dart
static const String monthlyPlan = 'TU_ID_MENSUAL_AQUI';
static const String yearlyPlan = 'TU_ID_ANUAL_AQUI';
```

3. Recompila y reinstala la app

## 9. Contacto

Si después de seguir estos pasos el problema persiste, comparte:
- Los logs completos de la verificación
- Los IDs de productos en Google Play Console
- El estado de la suscripción en Google Play Console

