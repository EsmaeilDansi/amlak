// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 7;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.Req;
      case 1:
        return MessageType.Sale;
      default:
        return MessageType.Req;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.Req:
        writer.writeByte(0);
        break;
      case MessageType.Sale:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
