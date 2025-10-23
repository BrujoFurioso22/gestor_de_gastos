import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import 'hive_service.dart';

class AdMobService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static bool _isInitialized = false;

  /// Inicializa AdMob
  static Future<void> init() async {
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  /// Crea un banner ad
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AppConstants.adMobBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('Banner ad opened');
        },
        onAdClosed: (ad) {
          print('Banner ad closed');
        },
      ),
    );
  }

  /// Carga un banner ad
  static Future<BannerAd?> loadBannerAd() async {
    if (!_isInitialized) {
      await init();
    }

    // Verificar si el usuario es premium
    final settings = HiveService.getAppSettings();
    if (settings.isPremium) {
      return null;
    }

    try {
      _bannerAd = createBannerAd();
      await _bannerAd!.load();
      return _bannerAd;
    } catch (e) {
      print('Error loading banner ad: $e');
      return null;
    }
  }

  /// Carga un anuncio interstitial
  static Future<void> loadInterstitialAd() async {
    if (!_isInitialized) {
      await init();
    }

    // Verificar si el usuario es premium
    final settings = HiveService.getAppSettings();
    if (settings.isPremium) {
      return;
    }

    // Verificar cooldown
    final now = DateTime.now();
    final lastAdShown = settings.lastAdShown;
    if (now.difference(lastAdShown) < AppConstants.adCooldown) {
      return;
    }

    try {
      await InterstitialAd.load(
        adUnitId: AppConstants.adMobInterstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _showInterstitialAd();
          },
          onAdFailedToLoad: (error) {
            print('Interstitial ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      print('Error loading interstitial ad: $e');
    }
  }

  /// Muestra un anuncio interstitial
  static void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('Interstitial ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('Interstitial ad dismissed');
          ad.dispose();
          _interstitialAd = null;
          _updateAdShownTime();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Interstitial ad failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
        },
      );
      _interstitialAd!.show();
    }
  }

  /// Verifica si debe mostrar un anuncio interstitial
  static Future<void> checkAndShowInterstitialAd() async {
    final settings = HiveService.getAppSettings();

    // Verificar si el usuario es premium
    if (settings.isPremium) {
      return;
    }

    // Verificar frecuencia de anuncios
    if (settings.appOpenCount % AppConstants.adFrequency == 0) {
      await loadInterstitialAd();
    }
  }

  /// Incrementa el contador de aperturas de la app
  static Future<void> incrementAppOpenCount() async {
    final settings = HiveService.getAppSettings();
    final updatedSettings = settings.copyWith(
      appOpenCount: settings.appOpenCount + 1,
    );
    await HiveService.saveAppSettings(updatedSettings);
  }

  /// Actualiza el tiempo del último anuncio mostrado
  static Future<void> _updateAdShownTime() async {
    final settings = HiveService.getAppSettings();
    final updatedSettings = settings.copyWith(lastAdShown: DateTime.now());
    await HiveService.saveAppSettings(updatedSettings);
  }

  /// Libera los recursos de los anuncios
  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
  }

  /// Verifica si los anuncios están habilitados
  static bool areAdsEnabled() {
    final settings = HiveService.getAppSettings();
    return !settings.isPremium;
  }

  /// Habilita/deshabilita los anuncios (para versión premium)
  static Future<void> setAdsEnabled(bool enabled) async {
    final settings = HiveService.getAppSettings();
    final updatedSettings = settings.copyWith(isPremium: !enabled);
    await HiveService.saveAppSettings(updatedSettings);
  }
}
