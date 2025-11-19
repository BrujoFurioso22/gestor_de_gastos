import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Provider del servicio de compras
final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService();
});

/// IDs de los productos (configurar en Google Play Console y App Store Connect)
class PremiumProducts {
  static const String monthlyPlan = 'cuidatuplata_sus_mensual';
  static const String yearlyPlan = 'cuidatuplata_sus_anual';

  static const Set<String> productIds = {monthlyPlan, yearlyPlan};
}

class PremiumService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  /// Verifica si la compra está disponible
  Future<bool> isAvailable() async {
    return await _inAppPurchase.isAvailable();
  }

  /// Obtiene los productos disponibles
  Future<ProductDetailsResponse> getProducts() async {
    return await _inAppPurchase.queryProductDetails(PremiumProducts.productIds);
  }

  /// Realiza una compra
  Future<void> purchaseProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);

    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Procesa las compras pendientes
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  /// Verifica las compras activas y las restaura
  /// Esto debe llamarse al iniciar la app para sincronizar el estado premium
  Future<void> verifyActivePurchases() async {
    try {
      // Verificar disponibilidad
      final purchasesAvailable = await isAvailable();

      if (!purchasesAvailable) {
        return;
      }

      // Restaurar compras para obtener las compras activas de Google Play
      // Las compras restauradas llegarán a través del stream purchaseUpdates
      // El listener en main_navigation.dart las procesará automáticamente
      await restorePurchases();
    } catch (e) {
      // Silenciar errores de verificación, no es crítico si falla
      // El stream de compras seguirá funcionando
    }
  }

  /// Escucha las actualizaciones de compras
  Stream<List<PurchaseDetails>> get purchaseUpdates =>
      _inAppPurchase.purchaseStream;
}
