class AppConstants {
  // Información de la app
  static const String appName = 'CuidaTuPlata';
  static const String appVersion = '1.0.0';

  // Configuración de AdMob
  static const String adMobAppId =
      'ca-app-pub-3940256099942544~3347511713'; // ID de prueba
  static const String adMobBannerId =
      'ca-app-pub-3940256099942544/6300978111'; // Banner de prueba
  static const String adMobInterstitialId =
      'ca-app-pub-3940256099942544/1033173712'; // Interstitial de prueba

  // Configuración de anuncios
  static const int adFrequency = 5; // Mostrar anuncio cada 5 aperturas
  static const Duration adCooldown = Duration(
    hours: 1,
  ); // Cooldown entre anuncios

  // Configuración de Hive
  static const String transactionsBoxName = 'transactions';
  static const String categoriesBoxName = 'categories';
  static const String settingsBoxName = 'settings';
  static const String subscriptionsBoxName = 'subscriptions';
  static const String appConfigBoxName = 'app_config';

  // Configuración de moneda
  static const String defaultCurrency = 'EUR';
  static const String currencySymbol = '€';

  // Configuración de idioma
  static const String defaultLanguage = 'es';

  // Límites
  static const int maxTransactionAmount = 999999;
  static const int maxTitleLength = 100;
  static const int maxNotesLength = 500;

  // Colores del tema
  static const Map<String, String> themeColors = {
    'primary': '#6750A4',
    'secondary': '#625B71',
    'tertiary': '#7D5260',
    'error': '#BA1A1A',
    'success': '#4CAF50',
    'warning': '#FF9800',
    'info': '#2196F3',
  };

  // Configuración de gráficos
  static const int maxChartItems = 10;
  static const double chartAnimationDuration = 1.5;

  // Configuración de UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Configuración de animaciones
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
