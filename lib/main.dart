import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/hive_service.dart';
import 'services/admob_service.dart';
import 'widgets/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formatos de fecha para todos los locales
  await initializeDateFormatting();

  // Inicializar Hive
  await HiveService.init();

  // Inicializar AdMob
  await AdMobService.init();

  runApp(const ProviderScope(child: AppInitializer()));
}
