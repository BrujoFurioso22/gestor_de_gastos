import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_config_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';
import '../views/splash_screen.dart';

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final appConfig = ref.watch(appConfigProvider);

    // Inicializar la configuración si no está lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appConfigProvider.notifier).initializeConfig();
    });

    // Construir el tema según la configuración
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    );

    final lightTheme = AppThemeBuilder.buildTheme(
      lightColorScheme,
      Brightness.light,
      appConfig.fontSize,
    );

    final darkTheme = AppThemeBuilder.buildTheme(
      darkColorScheme,
      Brightness.dark,
      appConfig.fontSize,
    );

    return MaterialApp(
      title: 'MiControl',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
