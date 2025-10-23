import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../providers/settings_provider.dart';

/// Provider para el estado de AdMob
final adMobStateProvider = StateNotifierProvider<AdMobNotifier, AdMobState>((
  ref,
) {
  return AdMobNotifier();
});

/// Provider para verificar si los anuncios están habilitados
final adsEnabledProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  return !isPremium;
});

/// Provider para el banner ad
final bannerAdProvider = FutureProvider<BannerAd?>((ref) async {
  final adsEnabled = ref.watch(adsEnabledProvider);
  if (!adsEnabled) return null;

  return await AdMobService.loadBannerAd();
});

/// Estado de AdMob
class AdMobState {
  final bool isInitialized;
  final bool isBannerLoaded;
  final bool isInterstitialLoaded;
  final String? error;

  const AdMobState({
    this.isInitialized = false,
    this.isBannerLoaded = false,
    this.isInterstitialLoaded = false,
    this.error,
  });

  AdMobState copyWith({
    bool? isInitialized,
    bool? isBannerLoaded,
    bool? isInterstitialLoaded,
    String? error,
  }) {
    return AdMobState(
      isInitialized: isInitialized ?? this.isInitialized,
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      isInterstitialLoaded: isInterstitialLoaded ?? this.isInterstitialLoaded,
      error: error ?? this.error,
    );
  }
}

/// Notifier para manejar el estado de AdMob
class AdMobNotifier extends StateNotifier<AdMobState> {
  AdMobNotifier() : super(const AdMobState()) {
    _initialize();
  }

  /// Inicializa AdMob
  Future<void> _initialize() async {
    try {
      await AdMobService.init();
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Carga un banner ad
  Future<void> loadBannerAd() async {
    if (!state.isInitialized) {
      await _initialize();
    }

    try {
      final bannerAd = await AdMobService.loadBannerAd();
      state = state.copyWith(isBannerLoaded: bannerAd != null, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Carga un anuncio interstitial
  Future<void> loadInterstitialAd() async {
    if (!state.isInitialized) {
      await _initialize();
    }

    try {
      await AdMobService.loadInterstitialAd();
      state = state.copyWith(isInterstitialLoaded: true, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Verifica y muestra un anuncio interstitial si es necesario
  Future<void> checkAndShowInterstitialAd() async {
    if (!state.isInitialized) {
      await _initialize();
    }

    try {
      await AdMobService.checkAndShowInterstitialAd();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Incrementa el contador de aperturas de la app
  Future<void> incrementAppOpenCount() async {
    await AdMobService.incrementAppOpenCount();
  }

  /// Habilita/deshabilita los anuncios
  Future<void> setAdsEnabled(bool enabled) async {
    await AdMobService.setAdsEnabled(enabled);
  }

  /// Libera los recursos
  @override
  void dispose() {
    AdMobService.dispose();
    super.dispose();
  }

  /// Refresca el estado
  void refresh() {
    _initialize();
  }
}

/// Provider para manejar la lógica de anuncios
final adManagerProvider = Provider<AdManager>((ref) {
  return AdManager(ref);
});

/// Clase para manejar la lógica de anuncios
class AdManager {
  final Ref ref;

  AdManager(this.ref);

  /// Inicializa los anuncios
  Future<void> initialize() async {
    await ref.read(adMobStateProvider.notifier)._initialize();
  }

  /// Maneja la apertura de la app
  Future<void> handleAppOpen() async {
    // Incrementar contador de aperturas
    await ref.read(adMobStateProvider.notifier).incrementAppOpenCount();

    // Verificar si se debe mostrar un anuncio
    await ref.read(adMobStateProvider.notifier).checkAndShowInterstitialAd();
  }

  /// Carga un banner ad
  Future<void> loadBanner() async {
    await ref.read(adMobStateProvider.notifier).loadBannerAd();
  }

  /// Carga un anuncio interstitial
  Future<void> loadInterstitial() async {
    await ref.read(adMobStateProvider.notifier).loadInterstitialAd();
  }

  /// Verifica si los anuncios están habilitados
  bool areAdsEnabled() {
    return ref.read(adsEnabledProvider);
  }

  /// Habilita/deshabilita los anuncios
  Future<void> setAdsEnabled(bool enabled) async {
    await ref.read(adMobStateProvider.notifier).setAdsEnabled(enabled);
  }
}
