import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/settings_provider.dart';

/// Helper para procesar compras
class PurchaseHelper {
  /// Procesa una compra
  static Future<void> processPurchase(
    PurchaseDetails purchase,
    WidgetRef ref,
  ) async {
    final inAppPurchase = InAppPurchase.instance;

    try {
      debugPrint('Procesando compra: ${purchase.productID}, estado: ${purchase.status}');

      if (purchase.status == PurchaseStatus.purchased) {
        // Activar premium en la configuración
        await ref.read(settingsProvider.notifier).setPremium(true);
        debugPrint('Premium activado para producto: ${purchase.productID}');

        // Si la compra no está finalizada, finalizarla
        if (purchase.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchase);
          debugPrint('Compra finalizada: ${purchase.productID}');
        } else {
          // La compra ya está completada (por ejemplo, al restaurar compras)
          debugPrint('Compra ya completada: ${purchase.productID}');
        }
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Error en compra: ${purchase.error?.message}');
      } else if (purchase.status == PurchaseStatus.canceled) {
        debugPrint('Compra cancelada: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.pending) {
        debugPrint('Compra pendiente: ${purchase.productID}');
      }
    } catch (e) {
      debugPrint('Error procesando compra: $e');
      rethrow;
    }
  }
}
