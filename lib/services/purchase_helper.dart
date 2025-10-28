import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/settings_provider.dart';

/// Helper para procesar compras
class PurchaseHelper {
  /// Procesa una compra exitosa
  static Future<void> processPurchase(
    PurchaseDetails purchase,
    WidgetRef ref,
  ) async {
    final inAppPurchase = InAppPurchase.instance;

    if (purchase.status == PurchaseStatus.purchased) {
      // Activar premium en la configuración
      await ref.read(settingsProvider.notifier).setPremium(true);

      // Si la compra no está finalizada, finalizarla
      if (purchase.pendingCompletePurchase) {
        await inAppPurchase.completePurchase(purchase);
      }
    }
  }
}
