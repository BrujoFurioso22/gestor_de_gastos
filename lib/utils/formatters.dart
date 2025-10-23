import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'es_ES');

  /// Formatea una fecha en formato dd/MM/yyyy
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formatea una hora en formato HH:mm
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// Formatea fecha y hora en formato dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Formatea mes y año en formato MMM yyyy
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Formatea día y mes en formato dd MMM
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Formatea una cantidad como moneda
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formatea una cantidad como moneda (alias para formatCurrency)
  static String formatAmount(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formatea una cantidad como número
  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }

  /// Formatea una cantidad con signo positivo/negativo
  static String formatAmountWithSign(double amount, {bool showSign = true}) {
    if (amount == 0) return '€0,00';

    final formatted = _currencyFormat.format(amount.abs());
    if (showSign) {
      return amount > 0 ? '+$formatted' : '-$formatted';
    }
    return formatted;
  }

  /// Formatea una fecha relativa (hoy, ayer, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hoy';
    } else if (targetDate == yesterday) {
      return 'Ayer';
    } else {
      final difference = today.difference(targetDate).inDays;
      if (difference < 7) {
        return 'Hace $difference días';
      } else {
        return formatDate(date);
      }
    }
  }

  /// Formatea un período de tiempo
  static String formatPeriod(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${formatDayMonth(start)} - ${formatDayMonth(end)}';
    } else if (start.year == end.year) {
      return '${formatDayMonth(start)} - ${formatDayMonth(end)} ${end.year}';
    } else {
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }

  /// Obtiene el nombre del mes en español
  static String getMonthName(int month) {
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

  /// Obtiene el nombre del día de la semana en español
  static String getWeekdayName(int weekday) {
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
