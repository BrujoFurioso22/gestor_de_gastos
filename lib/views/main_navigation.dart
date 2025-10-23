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
    return Scaffold(
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
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIconsStrokeRounded.home01, size: 24),
                label: SimpleLocalization.getText(ref, 'dashboard'),
              ),
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIconsStrokeRounded.clock01, size: 24),
                label: SimpleLocalization.getText(ref, 'history'),
              ),
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIconsStrokeRounded.money01, size: 24),
                label: SimpleLocalization.getText(ref, 'subscriptions'),
              ),
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIconsStrokeRounded.menu01, size: 24),
                label: SimpleLocalization.getText(ref, 'settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
