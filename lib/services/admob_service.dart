import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import 'hive_service.dart';

class AdMobService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static bool _isInitialized = false;
  static bool _isLoadingBanner = false;
  static DateTime? _lastBannerLoadAttempt;
  static int _consecutiveFailures = 0;
  
  // Tiempo mínimo entre intentos de carga (para evitar "too many requests")
  static const Duration _minRetryDelay = Duration(seconds: 30);
  static const int _maxConsecutiveFailures = 3;

  /// Obtiene el ID de banner según el modo (debug/producción)
  static String getBannerAdUnitId() {
    if (kDebugMode) {
      // En modo debug, usar IDs de prueba
      return AppConstants.adMobTestBannerId;
    }
    return AppConstants.adMobBannerId;
  }

  /// Obtiene el ID de interstitial según el modo (debug/producción)
  static String getInterstitialAdUnitId() {
    if (kDebugMode) {
      // En modo debug, usar IDs de prueba
      return AppConstants.adMobTestInterstitialId;
    }
    return AppConstants.adMobInterstitialId;
  }

  /// Inicializa AdMob
  static Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ AdMob inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error al inicializar AdMob: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Verifica si se puede intentar cargar un anuncio (evita demasiados intentos)
  static bool _canAttemptLoad() {
    if (_lastBannerLoadAttempt == null) {
      return true;
    }

    final timeSinceLastAttempt = DateTime.now().difference(_lastBannerLoadAttempt!);
    
    // Si hay demasiados fallos consecutivos, esperar más tiempo
    if (_consecutiveFailures >= _maxConsecutiveFailures) {
      if (timeSinceLastAttempt < const Duration(minutes: 5)) {
        debugPrint('⏳ Esperando antes de reintentar (demasiados fallos consecutivos)');
        return false;
      }
      // Resetear contador después de esperar
      _consecutiveFailures = 0;
    } else if (timeSinceLastAttempt < _minRetryDelay) {
      debugPrint('⏳ Esperando antes de reintentar (${timeSinceLastAttempt.inSeconds}s/${_minRetryDelay.inSeconds}s)');
      return false;
    }

    return true;
  }

  /// Analiza el error y proporciona información útil
  static void _analyzeError(LoadAdError error) {
    debugPrint('📊 Análisis de error de AdMob:');
    debugPrint('   Código: ${error.code}');
    debugPrint('   Mensaje: ${error.message}');
    debugPrint('   Dominio: ${error.domain}');
    debugPrint('   Respuesta: ${error.responseInfo}');

    // Errores comunes y sus soluciones
    switch (error.code) {
      case 3: // ERROR_CODE_NO_FILL o Publisher data not found
        debugPrint('⚠️  Error 3: Publisher data not found');
        debugPrint('   Solución: Verifica que:');
        debugPrint('   1. Tu cuenta de AdMob esté completamente configurada');
        debugPrint('   2. Los IDs de anuncios estén correctamente vinculados');
        debugPrint('   3. El archivo app-ads.txt esté accesible en tu dominio');
        debugPrint('   4. La app esté publicada en Play Store (si usas IDs de producción)');
        break;
      case 1: // ERROR_CODE_INTERNAL_ERROR o Too many requests
        debugPrint('⚠️  Error 1: Too many recently failed requests');
        debugPrint('   Solución: Espera unos minutos antes de reintentar');
        break;
      case 0: // ERROR_CODE_INTERNAL_ERROR
        debugPrint('⚠️  Error 0: Error interno de AdMob');
        debugPrint('   Solución: Intenta más tarde');
        break;
      case 2: // ERROR_CODE_NETWORK_ERROR
        debugPrint('⚠️  Error 2: Error de red');
        debugPrint('   Solución: Verifica tu conexión a internet');
        break;
      default:
        debugPrint('⚠️  Error desconocido: ${error.code}');
    }
  }

  /// Carga un banner ad con mejor manejo de errores y retry
  static Future<BannerAd?> loadBannerAd() async {
    // Si ya hay un banner cargado, no crear uno nuevo
    if (_bannerAd != null) {
      debugPrint('✅ Banner ya está cargado');
      return _bannerAd;
    }

    // Prevenir múltiples intentos simultáneos
    if (_isLoadingBanner) {
      debugPrint('⏳ Banner ya se está cargando, esperando...');
      return null;
    }

    // Verificar si se puede intentar cargar
    if (!_canAttemptLoad()) {
      return null;
    }

    if (!_isInitialized) {
      await init();
    }

    // Verificar si el usuario es premium
    final settings = HiveService.getAppSettings();
    if (settings.isPremium) {
      debugPrint('👑 Usuario premium, no se cargan anuncios');
      return null;
    }

    _isLoadingBanner = true;
    _lastBannerLoadAttempt = DateTime.now();

    try {
      final completer = Completer<BannerAd?>();
      final adUnitId = getBannerAdUnitId();

      debugPrint('🔄 Intentando cargar banner ad (ID: ${kDebugMode ? "TEST" : "PRODUCTION"})');

      final newBanner = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            // El anuncio se cargó correctamente
            debugPrint('✅ Banner ad cargado correctamente');
            _consecutiveFailures = 0; // Resetear contador de fallos
            if (!completer.isCompleted) {
              completer.complete(ad as BannerAd);
            }
          },
          onAdFailedToLoad: (ad, error) {
            // El anuncio falló al cargar
            _consecutiveFailures++;
            debugPrint('❌ Banner ad falló al cargar (intento $_consecutiveFailures/$_maxConsecutiveFailures)');
            _analyzeError(error);
            ad.dispose();
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
          onAdOpened: (ad) {
            debugPrint('👆 Banner ad abierto');
          },
          onAdClosed: (ad) {
            debugPrint('👋 Banner ad cerrado');
          },
        ),
      );

      // Iniciar la carga del anuncio
      newBanner.load();

      // Esperar a que el anuncio se cargue con timeout de 15 segundos
      final loadedAd = await completer.future
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏱️  Banner ad load timeout (15s)');
              newBanner.dispose();
              _consecutiveFailures++;
              return null;
            },
          )
          .catchError((error) {
            debugPrint('❌ Banner ad load error: $error');
            newBanner.dispose();
            _consecutiveFailures++;
            return null;
          });

      if (loadedAd != null) {
        _bannerAd = loadedAd;
        _isLoadingBanner = false;
        return _bannerAd;
      }

      newBanner.dispose();
      _isLoadingBanner = false;
      return null;
    } catch (e) {
      debugPrint('❌ Banner ad exception: $e');
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoadingBanner = false;
      _consecutiveFailures++;
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
      debugPrint('👑 Usuario premium, no se cargan anuncios intersticiales');
      return;
    }

    // Verificar cooldown
    final now = DateTime.now();
    final lastAdShown = settings.lastAdShown;
    if (now.difference(lastAdShown) < AppConstants.adCooldown) {
      final remainingTime = AppConstants.adCooldown - now.difference(lastAdShown);
      debugPrint('⏳ Cooldown activo, esperando ${remainingTime.inMinutes} minutos');
      return;
    }

    try {
      final adUnitId = getInterstitialAdUnitId();
      debugPrint('🔄 Intentando cargar interstitial ad (ID: ${kDebugMode ? "TEST" : "PRODUCTION"})');
      
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Interstitial ad cargado correctamente');
            _interstitialAd = ad;
            _showInterstitialAd();
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Interstitial ad falló al cargar');
            _analyzeError(error);
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Interstitial ad exception: $e');
    }
  }

  /// Muestra un anuncio interstitial
  static void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('👆 Interstitial ad mostrado');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('👋 Interstitial ad cerrado');
          ad.dispose();
          _interstitialAd = null;
          _updateAdShownTime();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('❌ Interstitial ad falló al mostrar: ${error.message}');
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
    debugPrint('🗑️  Liberando recursos de AdMob');
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isLoadingBanner = false;
    _consecutiveFailures = 0;
    _lastBannerLoadAttempt = null;
  }

  /// Resetea el estado de carga (útil para forzar un nuevo intento)
  static void resetLoadState() {
    debugPrint('🔄 Reseteando estado de carga de AdMob');
    _isLoadingBanner = false;
    _consecutiveFailures = 0;
    _lastBannerLoadAttempt = null;
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
