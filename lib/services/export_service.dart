import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/hive_service.dart';
import '../providers/app_config_provider.dart';
import '../utils/app_formatters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExportService {
  /// Solicita permisos de almacenamiento
  /// Nota: Para Android 10+, no se requieren permisos para guardar en el directorio de la app
  static Future<bool> requestStoragePermission() async {
    // En Android 10+ (API 29+), no se necesitan permisos para guardar en el directorio de la app
    // Solo se necesitan si queremos guardar en almacenamiento externo público
    // Como estamos usando getApplicationDocumentsDirectory(), no se requieren permisos
    return true;
  }

  /// Exporta transacciones a Excel
  static Future<String?> exportToExcel(
    List<Transaction> transactions,
    WidgetRef ref,
  ) async {
    try {
      debugPrint(
        'Iniciando exportación a Excel con ${transactions.length} transacciones',
      );

      if (transactions.isEmpty) {
        debugPrint('No hay transacciones para exportar');
        throw Exception('No hay transacciones para exportar');
      }

      // Crear archivo Excel
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Transacciones'];

      debugPrint('Hoja de Excel creada');

      // Obtener todas las categorías
      final categories = HiveService.getAllCategories();
      final categoryMap = {for (var cat in categories) cat.id: cat};

      // Encabezados
      final headers = [
        'Fecha',
        'Tipo',
        'Título',
        'Categoría',
        'Monto',
        'Notas',
        'Cuenta',
      ];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(bold: true);
      }

      // Agregar datos
      debugPrint('Agregando ${transactions.length} transacciones al Excel...');
      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        debugPrint(
          'Procesando transacción ${i + 1}: ${transaction.title}, ${transaction.amount}, ${transaction.date}',
        );

        final category = categoryMap[transaction.category];
        final categoryName = category != null
            ? (DefaultCategories.isDefaultCategory(category.id)
                  ? DefaultCategories.getTranslatedName(
                      category.id,
                      ref.read(appConfigProvider).language,
                    )
                  : category.name)
            : transaction.category;

        final row = i + 1;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = TextCellValue(
          AppFormatters.formatDate(transaction.date, ref),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = TextCellValue(
          transaction.type == TransactionType.income ? 'Ingreso' : 'Gasto',
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = TextCellValue(
          transaction.title ?? '',
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
            .value = TextCellValue(
          categoryName,
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
            .value = DoubleCellValue(
          transaction.amount,
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
            .value = TextCellValue(
          transaction.notes ?? '',
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
            .value = TextCellValue(
          transaction.accountId ?? '',
        );
      }

      // Guardar archivo
      debugPrint('Guardando archivo Excel...');
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final filePath = '${directory.path}/transacciones_$timestamp.xlsx';
      debugPrint('Ruta del archivo: $filePath');

      final fileBytes = excel.save();
      if (fileBytes != null) {
        debugPrint('Archivo Excel generado, tamaño: ${fileBytes.length} bytes');
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        debugPrint('Archivo guardado exitosamente en: $filePath');
        return filePath;
      } else {
        debugPrint('Error: excel.save() retornó null');
        throw Exception('Error al generar el archivo Excel');
      }
    } catch (e) {
      debugPrint('Error exportando a Excel: $e');
      rethrow;
    }
  }

  /// Exporta transacciones a CSV
  static Future<String?> exportToCSV(
    List<Transaction> transactions,
    WidgetRef ref,
  ) async {
    try {
      debugPrint(
        'Iniciando exportación a CSV con ${transactions.length} transacciones',
      );

      if (transactions.isEmpty) {
        debugPrint('No hay transacciones para exportar');
        throw Exception('No hay transacciones para exportar');
      }

      // Obtener todas las categorías
      final categories = HiveService.getAllCategories();
      final categoryMap = {for (var cat in categories) cat.id: cat};

      // Crear contenido CSV
      final buffer = StringBuffer();

      // Encabezados
      buffer.writeln('Fecha,Tipo,Título,Categoría,Monto,Notas,Cuenta');

      // Agregar datos
      debugPrint('Agregando ${transactions.length} transacciones al CSV...');
      for (final transaction in transactions) {
        debugPrint(
          'Procesando transacción: ${transaction.title}, ${transaction.amount}, ${transaction.date}',
        );

        final category = categoryMap[transaction.category];
        final categoryName = category != null
            ? (DefaultCategories.isDefaultCategory(category.id)
                  ? DefaultCategories.getTranslatedName(
                      category.id,
                      ref.read(appConfigProvider).language,
                    )
                  : category.name)
            : transaction.category;

        final type = transaction.type == TransactionType.income
            ? 'Ingreso'
            : 'Gasto';
        final title = (transaction.title ?? '')
            .replaceAll(',', ';')
            .replaceAll('\n', ' ');
        final notes = (transaction.notes ?? '')
            .replaceAll(',', ';')
            .replaceAll('\n', ' ');
        final amount = transaction.amount.toStringAsFixed(2);
        final date = AppFormatters.formatDate(transaction.date, ref);
        final account = transaction.accountId ?? '';

        buffer.writeln(
          '$date,$type,"$title","$categoryName",$amount,"$notes","$account"',
        );
      }

      // Guardar archivo
      debugPrint('Guardando archivo CSV...');
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final filePath = '${directory.path}/transacciones_$timestamp.csv';
      debugPrint('Ruta del archivo: $filePath');

      final file = File(filePath);
      final content = buffer.toString();
      debugPrint(
        'Contenido CSV generado, tamaño: ${content.length} caracteres',
      );
      await file.writeAsString(content);
      debugPrint('Archivo guardado exitosamente en: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error exportando a CSV: $e');
      rethrow;
    }
  }

  /// Comparte el archivo exportado
  static Future<void> shareFile(String filePath) async {
    try {
      final file = XFile(filePath);
      // Usar shareXFiles con subject para mejor compatibilidad
      await Share.shareXFiles(
        [file],
        text: 'Exportación de transacciones',
        subject: 'Transacciones exportadas',
      );
    } catch (e) {
      debugPrint('Error compartiendo archivo: $e');
      rethrow;
    }
  }

  /// Guarda el archivo en una ubicación accesible usando file_picker
  static Future<String?> saveFileToDownloads(String filePath) async {
    try {
      if (Platform.isAndroid) {
        // En Android, intentar guardar en Downloads
        final directory = Directory('/storage/emulated/0/Download');
        bool exists = await directory.exists();
        if (!exists) {
          await directory.create(recursive: true);
        }

        if (await directory.exists()) {
          final fileName = filePath.split('/').last;
          final newPath = '${directory.path}/$fileName';
          final sourceFile = File(filePath);
          await sourceFile.copy(newPath);
          debugPrint('Archivo guardado en Downloads: $newPath');
          return newPath;
        }
      }
      // Si no se puede guardar en Downloads, retornar la ruta original
      return filePath;
    } catch (e) {
      debugPrint('Error guardando archivo en Downloads: $e');
      return filePath;
    }
  }
}
