import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'services/admob_service.dart';
import 'providers/settings_provider.dart';
import 'utils/theme.dart';
import 'views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await HiveService.init();

  // Inicializar AdMob
  await AdMobService.init();

  runApp(const ProviderScope(child: CuidaTuPlataAppSimple()));
}

class CuidaTuPlataAppSimple extends ConsumerWidget {
  const CuidaTuPlataAppSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'CuidaTuPlata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainNavigation(),
    );
  }
}
