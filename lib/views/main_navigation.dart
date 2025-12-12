import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/admob_provider.dart';
import '../services/admob_service.dart';
import '../services/premium_service.dart';
import '../services/purchase_helper.dart';
import '../services/simple_localization.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'services_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isInitializingAds = false;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const ServicesScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _handleAppOpen();
    _initializePremiumVerification();
  }

  /// Inicializa los anuncios
  Future<void> _initializeAds() async {
    // Evitar múltiples llamadas simultáneas
    if (_isBannerAdLoaded || _bannerAd != null) {
      return;
    }

    final adsEnabled = ref.read(adsEnabledProvider);
    if (adsEnabled) {
      try {
        final bannerAd = await AdMobService.loadBannerAd();
        if (mounted && bannerAd != null) {
          setState(() {
            _bannerAd = bannerAd;
            _isBannerAdLoaded = true;
          });
        }
      } catch (e) {
        // Silenciar errores de carga de anuncios
        debugPrint('Error loading banner ad: $e');
      }
    }
  }

  /// Maneja la apertura de la app
  Future<void> _handleAppOpen() async {
    await ref.read(adMobStateProvider.notifier).incrementAppOpenCount();
    await ref.read(adMobStateProvider.notifier).checkAndShowInterstitialAd();
  }

  /// Inicializa la verificación de compras premium
  Future<void> _initializePremiumVerification() async {
    try {
      final premiumService = ref.read(premiumServiceProvider);

      // Configurar listener permanente del stream de compras
      _purchaseSubscription = premiumService.purchaseUpdates.listen(
        (purchases) async {
          // Procesar todas las compras recibidas
          for (final purchase in purchases) {
            await PurchaseHelper.processPurchase(purchase, ref);
          }
        },
        onError: (error) {
          // Silenciar errores del stream
        },
      );

      // Verificar compras activas al iniciar la app
      // Esto sincroniza el estado premium con Google Play
      await premiumService.verifyActivePurchases();

      // Dar un pequeño delay para que las compras lleguen al stream
      // Google Play puede tardar unos segundos en responder
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      // Silenciar errores de inicialización
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el estado actual de los anuncios
    final adsEnabled = ref.watch(adsEnabledProvider);

    // Actualizar anuncios cuando cambie el estado premium
    // Usar un flag para evitar múltiples llamadas
    if (!_isInitializingAds) {
      _isInitializingAds = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (adsEnabled && _bannerAd == null && !_isBannerAdLoaded) {
          _initializeAds().then((_) {
            _isInitializingAds = false;
          });
        } else if (!adsEnabled && _bannerAd != null) {
          _bannerAd?.dispose();
          _bannerAd = null;
          _isBannerAdLoaded = false;
          _isInitializingAds = false;
          setState(() {});
        } else {
          _isInitializingAds = false;
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Banner ad - Solo mostrar si está cargado
            if (_bannerAd != null && _isBannerAdLoaded)
              Container(
                height: 50,
                width: double.infinity,
                child: AdWidget(ad: _bannerAd!),
              ),
            // Bottom navigation bar
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    HugeIconsStrokeRounded.home01,
                    isSelected: _currentIndex == 0,
                  ),
                  activeIcon: _buildNavIcon(
                    HugeIconsStrokeRounded.home01,
                    isSelected: true,
                  ),
                  label: SimpleLocalization.getText(ref, 'dashboard'),
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    HugeIconsStrokeRounded.clock01,
                    isSelected: _currentIndex == 1,
                  ),
                  activeIcon: _buildNavIcon(
                    HugeIconsStrokeRounded.clock01,
                    isSelected: true,
                  ),
                  label: SimpleLocalization.getText(ref, 'history'),
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    HugeIconsStrokeRounded.dashboardSquare02,
                    isSelected: _currentIndex == 2,
                  ),
                  activeIcon: _buildNavIcon(
                    HugeIconsStrokeRounded.dashboardSquare02,
                    isSelected: true,
                  ),
                  label: SimpleLocalization.getText(ref, 'services'),
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    HugeIconsStrokeRounded.menu01,
                    isSelected: _currentIndex == 3,
                  ),
                  activeIcon: _buildNavIcon(
                    HugeIconsStrokeRounded.menu01,
                    isSelected: true,
                  ),
                  label: SimpleLocalization.getText(ref, 'settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un ícono de navegación con indicador visual
  Widget _buildNavIcon(List<List<dynamic>> icon, {required bool isSelected}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            size: 24,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
