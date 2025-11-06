// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringPaymentAdapter extends TypeAdapter<RecurringPayment> {
  @override
  final int typeId = 14;

  @override
  RecurringPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringPayment(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      amount: fields[3] as double,
      frequency: fields[4] as RecurringFrequency,
      type: fields[5] as TransactionType,
      category: fields[6] as String,
      dayOfMonth: fields[7] as int?,
      startDate: fields[8] as DateTime,
      endDate: fields[9] as DateTime?,
      notes: fields[10] as String?,
      icon: fields[11] as String,
      color: fields[12] as String,
      isActive: fields[13] as bool,
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
      nextPaymentDate: fields[16] as DateTime?,
      accountId: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringPayment obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.dayOfMonth)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.icon)
      ..writeByte(12)
      ..write(obj.color)
      ..writeByte(13)
      ..write(obj.isActive)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.nextPaymentDate)
      ..writeByte(17)
      ..write(obj.accountId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringFrequencyAdapter extends TypeAdapter<RecurringFrequency> {
  @override
  final int typeId = 15;

  @override
  RecurringFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurringFrequency.daily;
      case 1:
        return RecurringFrequency.weekly;
      case 2:
        return RecurringFrequency.monthly;
      case 3:
        return RecurringFrequency.quarterly;
      case 4:
        return RecurringFrequency.yearly;
      default:
        return RecurringFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurringFrequency obj) {
    switch (obj) {
      case RecurringFrequency.daily:
        writer.writeByte(0);
        break;
      case RecurringFrequency.weekly:
        writer.writeByte(1);
        break;
      case RecurringFrequency.monthly:
        writer.writeByte(2);
        break;
      case RecurringFrequency.quarterly:
        writer.writeByte(3);
        break;
      case RecurringFrequency.yearly:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
