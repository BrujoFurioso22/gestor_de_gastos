import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/settings_provider.dart';
import '../services/premium_service.dart';

/// Helper para procesar compras
class PurchaseHelper {
  /// Procesa una compra
  static Future<void> processPurchase(
    PurchaseDetails purchase,
    WidgetRef ref,
  ) async {
    final inAppPurchase = InAppPurchase.instance;

    try {
      // Verificar si el producto ID coincide con nuestros productos premium
      final isPremiumProduct = PremiumProducts.productIds.contains(
        purchase.productID,
      );

      if (!isPremiumProduct) {
        return;
      }

      // Activar premium si la compra está comprada O restaurada
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Activar premium en la configuración
        await ref.read(settingsProvider.notifier).setPremium(true);

        // Si la compra no está finalizada, finalizarla
        if (purchase.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchase);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
