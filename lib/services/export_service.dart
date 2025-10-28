import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/account_provider.dart';
import '../providers/app_config_provider.dart';
import '../models/transaction.dart';

class ExportService {
  /// Formatea una fecha según la configuración de la app
  static String _formatDate(DateTime date, appConfig) {
    String pattern;
    switch (appConfig.dateFormat) {
      case 'DD/MM/YYYY':
        pattern = 'dd/MM/yyyy';
        break;
      case 'MM/DD/YYYY':
        pattern = 'MM/dd/yyyy';
        break;
      case 'YYYY-MM-DD':
        pattern = 'yyyy-MM-dd';
        break;
      default:
        pattern = 'dd/MM/yyyy';
    }
    return DateFormat(pattern).format(date);
  }

  /// Exporta transacciones a Excel
  static Future<String?> exportToExcel(WidgetRef ref) async {
    try {
      // Obtener datos
      final transactions = ref.read(transactionsProvider);
      final subscriptions = ref.read(subscriptionsProvider);
      final accounts = ref.read(accountProvider);
      final appConfig = ref.read(appConfigProvider);

      // Crear archivo Excel
      final excel = Excel.createExcel();
      final sheet = excel['Transacciones'];

      // Encabezados
      final headers = [
        'Fecha',
        'Tipo',
        'Categoría',
        'Descripción',
        'Monto',
        'Cuenta',
      ];

      for (int i = 0; i < headers.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(
          headers[i],
        );
      }

      // Datos de transacciones
      int row = 1;
      for (final transaction in transactions) {
        final account = accounts.firstWhere(
          (acc) => acc.id == transaction.accountId,
          orElse: () => accounts.isNotEmpty ? accounts.first : accounts.first,
        );

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = TextCellValue(
          _formatDate(transaction.date, appConfig),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = TextCellValue(
          transaction.type == TransactionType.income ? 'Ingreso' : 'Gasto',
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = TextCellValue(
          transaction.category.isNotEmpty
              ? transaction.category
              : 'Sin categoría',
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
            .value = TextCellValue(
          transaction.title ?? 'Sin título',
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
            .value = DoubleCellValue(
          transaction.amount,
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
            .value = TextCellValue(
          account.name,
        );
        row++;
      }

      // Hoja de suscripciones
      final subscriptionSheet = excel['Suscripciones'];
      final subscriptionHeaders = [
        'Nombre',
        'Descripción',
        'Monto',
        'Frecuencia',
        'Fecha de inicio',
        'Fecha de fin',
        'Estado',
      ];

      for (int i = 0; i < subscriptionHeaders.length; i++) {
        subscriptionSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(
          subscriptionHeaders[i],
        );
      }

      // Datos de suscripciones
      row = 1;
      for (final subscription in subscriptions) {
        subscriptionSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = TextCellValue(
          subscription.name,
        );
        subscriptionSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = TextCellValue(
          subscription.description,
        );
        subscriptionSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = DoubleCellValue(
          subscription.amount,
        );
        subscriptionSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
            .value = TextCellValue(
          subscription.frequency.name,
        );
        subscriptionSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
            .value = TextCellValue(
          _formatDate(subscription.startDate, appConfig),
        );
        subscriptionSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
            .value = TextCellValue(
          subscription.endDate != null
              ? _formatDate(subscription.endDate!, appConfig)
              : 'Sin fin',
        );
        subscriptionSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
            .value = TextCellValue(
          subscription.isActive ? 'Activa' : 'Inactiva',
        );
        row++;
      }

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'CuidaTuPlata_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory.path}/$fileName';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        return filePath;
      }

      return null;
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }

  /// Exporta transacciones a CSV
  static Future<String?> exportToCsv(WidgetRef ref) async {
    try {
      // Obtener datos
      final transactions = ref.read(transactionsProvider);
      final subscriptions = ref.read(subscriptionsProvider);
      final accounts = ref.read(accountProvider);
      final appConfig = ref.read(appConfigProvider);

      // Crear contenido CSV
      final csvContent = StringBuffer();

      // Encabezados
      csvContent.writeln('Fecha,Tipo,Categoría,Descripción,Monto,Cuenta');

      // Datos de transacciones
      for (final transaction in transactions) {
        final account = accounts.firstWhere(
          (acc) => acc.id == transaction.accountId,
          orElse: () => accounts.isNotEmpty ? accounts.first : accounts.first,
        );

        csvContent.writeln(
          [
            _formatDate(transaction.date, appConfig),
            transaction.type == TransactionType.income ? 'Ingreso' : 'Gasto',
            transaction.category.isNotEmpty
                ? transaction.category
                : 'Sin categoría',
            transaction.title ?? 'Sin título',
            transaction.amount.toString(),
            account.name,
          ].join(','),
        );
      }

      // Separador para suscripciones
      csvContent.writeln('\n--- SUSCRIPCIONES ---');
      csvContent.writeln(
        'Nombre,Descripción,Monto,Frecuencia,Fecha de inicio,Fecha de fin,Estado',
      );

      // Datos de suscripciones
      for (final subscription in subscriptions) {
        csvContent.writeln(
          [
            subscription.name,
            subscription.description,
            subscription.amount.toString(),
            subscription.frequency.name,
            _formatDate(subscription.startDate, appConfig),
            subscription.endDate != null
                ? _formatDate(subscription.endDate!, appConfig)
                : 'Sin fin',
            subscription.isActive ? 'Activa' : 'Inactiva',
          ].join(','),
        );
      }

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'CuidaTuPlata_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(csvContent.toString());
      return filePath;
    } catch (e) {
      throw Exception('Error al exportar a CSV: $e');
    }
  }

  /// Comparte el archivo exportado
  static Future<void> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Archivo exportado desde CuidaTuPlata');
      } else {
        throw Exception('El archivo no existe: $filePath');
      }
    } catch (e) {
      throw Exception('Error al compartir archivo: $e');
    }
  }
}
