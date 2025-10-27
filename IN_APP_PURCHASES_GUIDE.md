# Guía de Integración de Compras In-App

## 📱 Configuración para Android (Google Play Billing)

### 1. Crear productos en Google Play Console

1. Ve a [Google Play Console](https://play.google.com/console)
2. Selecciona tu aplicación
3. Navega a: **Monetización > Productos y suscripciones**
4. Clic en **Crear producto**
5. Crea los siguientes productos:

#### Producto 1: Premium Mensual

- **ID del producto**: `premium_monthly`
- **Nombre**: Premium Mensual
- **Descripción**: Acceso a todas las funciones premium por un mes
- **Precio**: Define el precio deseado
- **Estado**: Activo

#### Producto 2: Premium Anual

- **ID del producto**: `premium_yearly`
- **Nombre**: Premium Anual
- **Descripción**: Acceso a todas las funciones premium por un año (mejor precio)
- **Precio**: Define el precio deseado
- **Estado**: Activo

### 2. Agregar licencia de prueba (para testing)

1. En Google Play Console, ve a **Configuración > Licencia de prueba**
2. Agrega tu cuenta de Gmail como usuario de prueba
3. Publica tu app en canal interno o alpha

## 📱 Configuración para iOS (App Store Connect)

### 1. Crear productos en App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Selecciona tu aplicación
3. Navega a: **Monetización > Compras dentro de la app**
4. Clic en **Crear producto**
5. Crea los siguientes productos:

#### Producto 1: Premium Mensual

- **ID del producto**: `premium_monthly`
- **Referencia**: Compras dentro de la app no consumibles
- **Precio**: Define el precio deseado
- **Estado**: Listo para enviar

#### Producto 2: Premium Anual

- **ID del producto**: `premium_yearly`
- **Referencia**: Compras dentro de la app no consumibles
- **Precio**: Define el precio deseado
- **Estado**: Listo para enviar

### 2. Configurar para pruebas

1. En Xcode, configura **Capabilities > In-App Purchase**
2. Usa el simulador o un dispositivo real conectado a tu cuenta de prueba

## 🔧 Implementación en el código

### Modificar settings_screen.dart

El método `_processPurchase` debe usar el servicio real:

```dart
Future<void> _processPurchase(BuildContext context, WidgetRef ref, String planId) async {
  try {
    // Obtener el servicio de compras
    final premiumService = ref.read(premiumServiceProvider);

    // Verificar disponibilidad
    final isAvailable = await premiumService.isAvailable();
    if (!isAvailable) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Las compras no están disponibles')),
        );
      }
      return;
    }

    // Obtener productos
    final response = await premiumService.getProducts();
    if (response.notFoundIDs.isNotEmpty) {
      print('Productos no encontrados: ${response.notFoundIDs}');
    }

    // Encontrar el producto seleccionado
    final product = response.productDetails.firstWhere(
      (p) => p.id == planId,
      orElse: () => response.productDetails.first,
    );

    // Realizar la compra
    await premiumService.purchaseProduct(product);

    // Escuchar actualizaciones de compra (debe hacerse en initState)
    premiumService.purchaseUpdates.listen((purchases) async {
      for (final purchase in purchases) {
        await PurchaseHelper.processPurchase(purchase, ref);
        if (purchase.status == PurchaseStatus.purchased && context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(SimpleLocalization.getText(ref, 'purchaseSuccessful')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });

  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### Actualizar el diálogo de compras

```dart
Widget _buildPurchaseOption({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String productId,  // Cambiar price por productId
  required bool isBestValue,
  required VoidCallback onTap,
}) {
  // Cargar precio real del producto
  // ...
}
```

## ✅ Checklist de implementación

- [ ] Instalar dependencia: `flutter pub get`
- [ ] Configurar productos en Google Play Console
- [ ] Configurar productos en App Store Connect
- [ ] Agregar listeners de compra en `initState` de la pantalla
- [ ] Probar compras en modo de prueba
- [ ] Manejar casos de error
- [ ] Implementar restauración de compras

## 🧪 Testing

### Android (Google Play)

1. Publica la app en canal interno
2. Agrega usuarios de prueba en Google Play Console
3. Instala la app en un dispositivo con cuenta de prueba
4. Realiza compras de prueba (no se cobrarán)

### iOS (App Store)

1. Crea cuenta de prueba en App Store Connect
2. Configura el producto en Xcode
3. Prueba en simulador o dispositivo real
4. Realiza compras de prueba

## 📝 Notas importantes

- **IDs de productos**: Los IDs en el código (`premium_monthly`, `premium_yearly`) deben coincidir exactamente con los configurados en las consolas
- **Compras no consumibles**: Se usan `buyNonConsumable` porque una vez comprada, el premium se activa permanentemente
- **Validación**: En producción, valida las compras con tu propio servidor
- **Restaurar compras**: Siempre implementa la opción de restaurar compras para usuarios que cambian de dispositivo
