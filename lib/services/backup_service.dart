import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/app_settings.dart';
import '../models/subscription.dart';
import '../models/recurring_payment.dart';
import '../models/app_config.dart';
import '../models/account.dart';
import '../services/hive_service.dart';

class BackupService {
  /// Estructura del backup JSON
  static const String backupVersion = '1.0.0';

  /// Exporta todos los datos a un archivo JSON
  static Future<String?> exportBackup() async {
    try {
      debugPrint('Iniciando exportación de backup...');

      // Obtener todos los datos
      final transactions = HiveService.getAllTransactions();
      final categories = HiveService.getAllCategories();
      final appSettings = HiveService.getAppSettings();
      final subscriptions = HiveService.getAllSubscriptions();
      final recurringPayments = HiveService.getAllRecurringPayments();
      final appConfig = HiveService.getAppConfig();
      final accounts = HiveService.getAllAccounts();

      debugPrint(
        'Datos a exportar: ${transactions.length} transacciones, '
        '${categories.length} categorías, '
        '${subscriptions.length} suscripciones, '
        '${recurringPayments.length} pagos recurrentes, '
        '${accounts.length} cuentas',
      );

      // Crear estructura JSON
      final backupData = {
        'version': backupVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'data': {
          'transactions': transactions.map((t) => t.toJson()).toList(),
          'categories': categories.map((c) => c.toJson()).toList(),
          'appSettings': appSettings.toJson(),
          'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
          'recurringPayments':
              recurringPayments.map((r) => r.toJson()).toList(),
          'appConfig': appConfig.toJson(),
          'accounts': accounts.map((a) => a.toJson()).toList(),
        },
      };

      // Convertir a JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      debugPrint('JSON generado, tamaño: ${jsonString.length} caracteres');

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final fileName = 'backup_cuidatuplata_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(jsonString);
      debugPrint('Backup guardado exitosamente en: $filePath');

      return filePath;
    } catch (e) {
      debugPrint('Error exportando backup: $e');
      rethrow;
    }
  }

  /// Comparte el archivo de backup
  static Future<void> shareBackup(String filePath) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Backup de CuidaTuPlata',
        subject: 'Backup de datos',
      );
    } catch (e) {
      debugPrint('Error compartiendo backup: $e');
      rethrow;
    }
  }

  /// Importa datos desde un archivo JSON
  static Future<Map<String, dynamic>> importBackup() async {
    try {
      debugPrint('Iniciando importación de backup...');

      // Seleccionar archivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No se seleccionó ningún archivo');
      }

      final file = result.files.first;
      if (file.bytes == null) {
        throw Exception('El archivo está vacío');
      }

      // Leer y parsear JSON
      final jsonString = utf8.decode(file.bytes!);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validar versión
      final version = backupData['version'] as String?;
      if (version == null) {
        throw Exception('El archivo de backup no tiene versión');
      }

      debugPrint('Backup versión: $version');

      // Extraer datos
      final data = backupData['data'] as Map<String, dynamic>;

      // Contar elementos
      final transactionsCount =
          (data['transactions'] as List<dynamic>?)?.length ?? 0;
      final categoriesCount =
          (data['categories'] as List<dynamic>?)?.length ?? 0;
      final subscriptionsCount =
          (data['subscriptions'] as List<dynamic>?)?.length ?? 0;
      final recurringPaymentsCount =
          (data['recurringPayments'] as List<dynamic>?)?.length ?? 0;
      final accountsCount = (data['accounts'] as List<dynamic>?)?.length ?? 0;

      debugPrint(
        'Datos a importar: $transactionsCount transacciones, '
        '$categoriesCount categorías, '
        '$subscriptionsCount suscripciones, '
        '$recurringPaymentsCount pagos recurrentes, '
        '$accountsCount cuentas',
      );

      return {
        'transactions': transactionsCount,
        'categories': categoriesCount,
        'subscriptions': subscriptionsCount,
        'recurringPayments': recurringPaymentsCount,
        'accounts': accountsCount,
        'backupData': backupData,
      };
    } catch (e) {
      debugPrint('Error importando backup: $e');
      rethrow;
    }
  }

  /// Restaura los datos desde el backup
  static Future<void> restoreBackup(Map<String, dynamic> backupData) async {
    try {
      debugPrint('Iniciando restauración de backup...');

      final data = backupData['data'] as Map<String, dynamic>;

      // Restaurar transacciones
      if (data['transactions'] != null) {
        final transactionsJson = data['transactions'] as List<dynamic>;
        debugPrint('Restaurando ${transactionsJson.length} transacciones...');
        for (final json in transactionsJson) {
          final transaction = Transaction.fromJson(json as Map<String, dynamic>);
          await HiveService.addTransaction(transaction);
        }
      }

      // Restaurar categorías
      if (data['categories'] != null) {
        final categoriesJson = data['categories'] as List<dynamic>;
        debugPrint('Restaurando ${categoriesJson.length} categorías...');
        for (final json in categoriesJson) {
          final category = Category.fromJson(json as Map<String, dynamic>);
          await HiveService.categoriesBox.put(category.id, category);
        }
      }

      // Restaurar suscripciones
      if (data['subscriptions'] != null) {
        final subscriptionsJson = data['subscriptions'] as List<dynamic>;
        debugPrint('Restaurando ${subscriptionsJson.length} suscripciones...');
        for (final json in subscriptionsJson) {
          final subscription =
              Subscription.fromJson(json as Map<String, dynamic>);
          await HiveService.addSubscription(subscription);
        }
      }

      // Restaurar pagos recurrentes
      if (data['recurringPayments'] != null) {
        final recurringPaymentsJson =
            data['recurringPayments'] as List<dynamic>;
        debugPrint(
          'Restaurando ${recurringPaymentsJson.length} pagos recurrentes...',
        );
        for (final json in recurringPaymentsJson) {
          final recurringPayment =
              RecurringPayment.fromJson(json as Map<String, dynamic>);
          await HiveService.addRecurringPayment(recurringPayment);
        }
      }

      // Restaurar cuentas
      if (data['accounts'] != null) {
        final accountsJson = data['accounts'] as List<dynamic>;
        debugPrint('Restaurando ${accountsJson.length} cuentas...');
        for (final json in accountsJson) {
          final account = Account.fromJson(json as Map<String, dynamic>);
          await HiveService.addAccount(account);
        }
      }

      // Restaurar configuración de app
      if (data['appConfig'] != null) {
        debugPrint('Restaurando configuración de app...');
        final appConfigJson = data['appConfig'] as Map<String, dynamic>;
        final appConfig = AppConfig.fromJson(appConfigJson);
        await HiveService.updateAppConfig(appConfig);
      }

      // Restaurar settings (opcional, puede no estar en backups antiguos)
      if (data['appSettings'] != null) {
        debugPrint('Restaurando settings de app...');
        final appSettingsJson = data['appSettings'] as Map<String, dynamic>;
        final appSettings = AppSettings.fromJson(appSettingsJson);
        await HiveService.saveAppSettings(appSettings);
      }

      debugPrint('Backup restaurado exitosamente');
    } catch (e) {
      debugPrint('Error restaurando backup: $e');
      rethrow;
    }
  }
}

