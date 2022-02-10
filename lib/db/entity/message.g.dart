// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 2;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      value: fields[5] as int,
      uuid: fields[0] as String,
      owner_uuid: fields[1] as String,
      time: fields[2] as int,
      caption: fields[3] as String,
      messageType: fields[6] as MessageType,
      location: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.owner_uuid)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.caption)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.value)
      ..writeByte(6)
      ..write(obj.messageType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
