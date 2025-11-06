// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 5;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String,
      amount: fields[3] as double,
      frequency: fields[4] as SubscriptionFrequency,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime?,
      notes: fields[7] as String?,
      icon: fields[8] as String,
      color: fields[9] as String,
      isActive: fields[10] as bool,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
      nextPaymentDate: fields[13] as DateTime?,
      accountId: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(15)
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
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.icon)
      ..writeByte(9)
      ..write(obj.color)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.nextPaymentDate)
      ..writeByte(14)
      ..write(obj.accountId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubscriptionFrequencyAdapter extends TypeAdapter<SubscriptionFrequency> {
  @override
  final int typeId = 6;

  @override
  SubscriptionFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionFrequency.daily;
      case 1:
        return SubscriptionFrequency.weekly;
      case 2:
        return SubscriptionFrequency.monthly;
      case 3:
        return SubscriptionFrequency.quarterly;
      case 4:
        return SubscriptionFrequency.yearly;
      default:
        return SubscriptionFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionFrequency obj) {
    switch (obj) {
      case SubscriptionFrequency.daily:
        writer.writeByte(0);
        break;
      case SubscriptionFrequency.weekly:
        writer.writeByte(1);
        break;
      case SubscriptionFrequency.monthly:
        writer.writeByte(2);
        break;
      case SubscriptionFrequency.quarterly:
        writer.writeByte(3);
        break;
      case SubscriptionFrequency.yearly:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
