// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final int typeId = 7;

  @override
  AppConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfig(
      currency: fields[0] as String,
      dateFormat: fields[1] as String,
      decimalSeparator: fields[2] as String,
      showCents: fields[3] as bool,
      theme: fields[4] as String,
      fontSize: fields[5] as String,
      language: fields[6] as String,
      vibration: fields[7] as bool,
      sound: fields[8] as bool,
      subscriptionReminderDays: fields[9] as int,
      notificationsEnabled: fields[10] as bool,
      monthlyExpenseLimit: fields[11] as double,
      weeklySummary: fields[12] as bool,
      weekStartsOnMonday: fields[13] as bool,
      currentAccountId: fields[16] as String?,
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.currency)
      ..writeByte(1)
      ..write(obj.dateFormat)
      ..writeByte(2)
      ..write(obj.decimalSeparator)
      ..writeByte(3)
      ..write(obj.showCents)
      ..writeByte(4)
      ..write(obj.theme)
      ..writeByte(5)
      ..write(obj.fontSize)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.vibration)
      ..writeByte(8)
      ..write(obj.sound)
      ..writeByte(9)
      ..write(obj.subscriptionReminderDays)
      ..writeByte(10)
      ..write(obj.notificationsEnabled)
      ..writeByte(11)
      ..write(obj.monthlyExpenseLimit)
      ..writeByte(12)
      ..write(obj.weeklySummary)
      ..writeByte(13)
      ..write(obj.weekStartsOnMonday)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.currentAccountId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final int typeId = 8;

  @override
  Currency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Currency.usd;
      case 1:
        return Currency.eur;
      case 2:
        return Currency.mxn;
      case 3:
        return Currency.gbp;
      case 4:
        return Currency.cad;
      case 5:
        return Currency.aud;
      default:
        return Currency.usd;
    }
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    switch (obj) {
      case Currency.usd:
        writer.writeByte(0);
        break;
      case Currency.eur:
        writer.writeByte(1);
        break;
      case Currency.mxn:
        writer.writeByte(2);
        break;
      case Currency.gbp:
        writer.writeByte(3);
        break;
      case Currency.cad:
        writer.writeByte(4);
        break;
      case Currency.aud:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DateFormatAdapter extends TypeAdapter<DateFormat> {
  @override
  final int typeId = 9;

  @override
  DateFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DateFormat.ddMMyyyy;
      case 1:
        return DateFormat.mmDDyyyy;
      case 2:
        return DateFormat.yyyyMMdd;
      default:
        return DateFormat.ddMMyyyy;
    }
  }

  @override
  void write(BinaryWriter writer, DateFormat obj) {
    switch (obj) {
      case DateFormat.ddMMyyyy:
        writer.writeByte(0);
        break;
      case DateFormat.mmDDyyyy:
        writer.writeByte(1);
        break;
      case DateFormat.yyyyMMdd:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DecimalSeparatorAdapter extends TypeAdapter<DecimalSeparator> {
  @override
  final int typeId = 10;

  @override
  DecimalSeparator read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DecimalSeparator.dot;
      case 1:
        return DecimalSeparator.comma;
      default:
        return DecimalSeparator.dot;
    }
  }

  @override
  void write(BinaryWriter writer, DecimalSeparator obj) {
    switch (obj) {
      case DecimalSeparator.dot:
        writer.writeByte(0);
        break;
      case DecimalSeparator.comma:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecimalSeparatorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppThemeAdapter extends TypeAdapter<AppTheme> {
  @override
  final int typeId = 11;

  @override
  AppTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppTheme.light;
      case 1:
        return AppTheme.dark;
      case 2:
        return AppTheme.system;
      default:
        return AppTheme.light;
    }
  }

  @override
  void write(BinaryWriter writer, AppTheme obj) {
    switch (obj) {
      case AppTheme.light:
        writer.writeByte(0);
        break;
      case AppTheme.dark:
        writer.writeByte(1);
        break;
      case AppTheme.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FontSizeAdapter extends TypeAdapter<FontSize> {
  @override
  final int typeId = 12;

  @override
  FontSize read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FontSize.small;
      case 1:
        return FontSize.normal;
      case 2:
        return FontSize.large;
      default:
        return FontSize.small;
    }
  }

  @override
  void write(BinaryWriter writer, FontSize obj) {
    switch (obj) {
      case FontSize.small:
        writer.writeByte(0);
        break;
      case FontSize.normal:
        writer.writeByte(1);
        break;
      case FontSize.large:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FontSizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LanguageAdapter extends TypeAdapter<Language> {
  @override
  final int typeId = 13;

  @override
  Language read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Language.es;
      case 1:
        return Language.en;
      default:
        return Language.es;
    }
  }

  @override
  void write(BinaryWriter writer, Language obj) {
    switch (obj) {
      case Language.es:
        writer.writeByte(0);
        break;
      case Language.en:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
