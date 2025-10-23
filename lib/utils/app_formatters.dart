import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_config_provider.dart';

class AppFormatters {
  /// Obtiene el símbolo de moneda según la configuración
  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'MXN':
        return '\$';
      case 'GBP':
        return '£';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return '\$';
    }
  }

  /// Obtiene el locale según la configuración
  static String _getLocale(String language) {
    switch (language) {
      case 'es':
        return 'es_ES';
      case 'en':
        return 'en_US';
      default:
        return 'es_ES';
    }
  }

  /// Obtiene el formato de fecha según la configuración
  static String _getDateFormatPattern(String dateFormat) {
    switch (dateFormat) {
      case 'DD/MM/YYYY':
        return 'dd/MM/yyyy';
      case 'MM/DD/YYYY':
        return 'MM/dd/yyyy';
      case 'YYYY-MM-DD':
        return 'yyyy-MM-dd';
      default:
        return 'dd/MM/yyyy';
    }
  }

  /// Formatea una fecha según la configuración de la app
  static String formatDate(DateTime date, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final pattern = _getDateFormatPattern(appConfig.dateFormat);
    final locale = _getLocale(appConfig.language);
    final formatter = DateFormat(pattern, locale);
    return formatter.format(date);
  }

  /// Formatea una hora según la configuración de la app
  static String formatTime(DateTime time, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final locale = _getLocale(appConfig.language);
    final formatter = DateFormat('HH:mm', locale);
    return formatter.format(time);
  }

  /// Formatea fecha y hora según la configuración de la app
  static String formatDateTime(DateTime dateTime, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final datePattern = _getDateFormatPattern(appConfig.dateFormat);
    final locale = _getLocale(appConfig.language);
    final formatter = DateFormat('$datePattern HH:mm', locale);
    return formatter.format(dateTime);
  }

  /// Formatea una cantidad como moneda según la configuración de la app
  static String formatCurrency(double amount, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final symbol = _getCurrencySymbol(appConfig.currency);
    final decimalDigits = appConfig.showCents ? 2 : 0;
    final decimalSeparator = appConfig.decimalSeparator == '.' ? '.' : ',';
    final groupSeparator = appConfig.decimalSeparator == '.' ? ',' : '.';

    // Formatear el número manualmente
    String formattedNumber = _formatNumberWithSeparators(
      amount,
      decimalDigits,
      decimalSeparator,
      groupSeparator,
    );

    return '$symbol$formattedNumber';
  }

  /// Formatea una cantidad como moneda (alias para formatCurrency)
  static String formatAmount(double amount, WidgetRef ref) {
    return formatCurrency(amount, ref);
  }

  /// Formatea una cantidad con signo positivo/negativo según la configuración
  static String formatAmountWithSign(
    double amount,
    WidgetRef ref, {
    bool showSign = true,
  }) {
    if (amount == 0) {
      final appConfig = ref.read(appConfigProvider);
      final symbol = _getCurrencySymbol(appConfig.currency);
      final decimalSeparator = appConfig.decimalSeparator == '.' ? '.' : ',';
      final cents = appConfig.showCents ? '$decimalSeparator${'0' * 2}' : '';
      return '$symbol 0$cents';
    }

    final formatted = formatCurrency(amount.abs(), ref);
    if (showSign) {
      return amount > 0 ? '+$formatted' : '-$formatted';
    }
    return formatted;
  }

  /// Formatea una cantidad como número según la configuración de la app
  static String formatNumber(double number, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final decimalDigits = appConfig.showCents ? 2 : 0;
    final decimalSeparator = appConfig.decimalSeparator == '.' ? '.' : ',';
    final groupSeparator = appConfig.decimalSeparator == '.' ? ',' : '.';

    return _formatNumberWithSeparators(
      number,
      decimalDigits,
      decimalSeparator,
      groupSeparator,
    );
  }

  /// Formatea mes y año según la configuración de la app
  static String formatMonthYear(DateTime date, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final locale = _getLocale(appConfig.language);
    final formatter = DateFormat('MMM yyyy', locale);
    return formatter.format(date);
  }

  /// Formatea día y mes según la configuración de la app
  static String formatDayMonth(DateTime date, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final locale = _getLocale(appConfig.language);
    final formatter = DateFormat('dd MMM', locale);
    return formatter.format(date);
  }

  /// Formatea una fecha relativa según el idioma de la app
  static String formatRelativeDate(DateTime date, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return appConfig.language == 'en' ? 'Today' : 'Hoy';
    } else if (targetDate == yesterday) {
      return appConfig.language == 'en' ? 'Yesterday' : 'Ayer';
    } else {
      final difference = today.difference(targetDate).inDays;
      if (difference < 7) {
        if (appConfig.language == 'en') {
          return '$difference days ago';
        } else {
          return 'Hace $difference días';
        }
      } else {
        return formatDate(date, ref);
      }
    }
  }

  /// Obtiene el nombre del mes según el idioma de la app
  static String getMonthName(int month, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);

    if (appConfig.language == 'en') {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return months[month - 1];
    } else {
      const months = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
      return months[month - 1];
    }
  }

  /// Obtiene el nombre del día de la semana según el idioma de la app
  static String getWeekdayName(int weekday, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);

    if (appConfig.language == 'en') {
      const weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[weekday - 1];
    } else {
      const weekdays = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      return weekdays[weekday - 1];
    }
  }

  /// Formatea un período de tiempo según la configuración de la app
  static String formatPeriod(DateTime start, DateTime end, WidgetRef ref) {
    if (start.year == end.year && start.month == end.month) {
      return '${formatDayMonth(start, ref)} - ${formatDayMonth(end, ref)}';
    } else if (start.year == end.year) {
      return '${formatDayMonth(start, ref)} - ${formatDayMonth(end, ref)} ${end.year}';
    } else {
      return '${formatDate(start, ref)} - ${formatDate(end, ref)}';
    }
  }

  /// Formatea un número con separadores personalizados
  static String _formatNumberWithSeparators(
    double number,
    int decimalDigits,
    String decimalSeparator,
    String groupSeparator,
  ) {
    // Convertir a string con la cantidad de decimales especificada
    String numberStr = number.toStringAsFixed(decimalDigits);

    // Separar parte entera y decimal
    List<String> parts = numberStr.split('.');
    String integerPart = parts[0];
    String decimalPart = decimalDigits > 0 ? parts[1] : '';

    // Agregar separadores de miles a la parte entera
    String formattedInteger = _addGroupSeparators(integerPart, groupSeparator);

    // Construir el resultado final
    if (decimalDigits > 0 && decimalPart.isNotEmpty) {
      return '$formattedInteger$decimalSeparator$decimalPart';
    } else {
      return formattedInteger;
    }
  }

  /// Agrega separadores de miles a un número
  static String _addGroupSeparators(String number, String separator) {
    if (number.length <= 3) return number;

    String result = '';
    int count = 0;

    for (int i = number.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = separator + result;
        count = 0;
      }
      result = number[i] + result;
      count++;
    }

    return result;
  }
}
