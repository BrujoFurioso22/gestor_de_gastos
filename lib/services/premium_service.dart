import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Provider del servicio de compras
final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService();
});

/// IDs de los productos (configurar en Google Play Console y App Store Connect)
class PremiumProducts {
  static const String monthlyPlan = 'premium_monthly';
  static const String yearlyPlan = 'premium_yearly';

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

  /// Escucha las actualizaciones de compras
  Stream<List<PurchaseDetails>> get purchaseUpdates =>
      _inAppPurchase.purchaseStream;
}
