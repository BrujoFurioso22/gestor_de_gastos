import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../providers/admob_provider.dart';
import '../services/admob_service.dart';
import '../services/simple_localization.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'subscriptions_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  BannerAd? _bannerAd;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const SubscriptionsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAds();
    _handleAppOpen();
  }

  /// Inicializa los anuncios
  Future<void> _initializeAds() async {
    final adsEnabled = ref.read(adsEnabledProvider);
    if (adsEnabled) {
      _bannerAd = await AdMobService.loadBannerAd();
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Maneja la apertura de la app
  Future<void> _handleAppOpen() async {
    await ref.read(adMobStateProvider.notifier).incrementAppOpenCount();
    await ref.read(adMobStateProvider.notifier).checkAndShowInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el estado actual de los anuncios
    final adsEnabled = ref.watch(adsEnabledProvider);

    // Actualizar anuncios cuando cambie el estado premium
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (adsEnabled && _bannerAd == null) {
        _initializeAds();
      } else if (!adsEnabled && _bannerAd != null) {
        _bannerAd?.dispose();
        _bannerAd = null;
        setState(() {});
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner ad
          if (_bannerAd != null)
            Container(
              height: 50,
              width: double.infinity,
              child: AdWidget(ad: _bannerAd!),
            ),
          // Bottom navigation bar
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
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
                  HugeIconsStrokeRounded.money01,
                  isSelected: _currentIndex == 2,
                ),
                activeIcon: _buildNavIcon(
                  HugeIconsStrokeRounded.money01,
                  isSelected: true,
                ),
                label: SimpleLocalization.getText(ref, 'subscriptions'),
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
