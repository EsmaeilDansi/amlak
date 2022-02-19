// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 4;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.ajara_dadan;
      case 1:
        return MessageType.rahn_dadan;
      case 2:
        return MessageType.forosh;
      case 3:
        return MessageType.kharid;
      case 4:
        return MessageType.ajara_kardan;
      case 5:
        return MessageType.rahn_kardan;
      default:
        return MessageType.ajara_dadan;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.ajara_dadan:
        writer.writeByte(0);
        break;
      case MessageType.rahn_dadan:
        writer.writeByte(1);
        break;
      case MessageType.forosh:
        writer.writeByte(2);
        break;
      case MessageType.kharid:
        writer.writeByte(3);
        break;
      case MessageType.ajara_kardan:
        writer.writeByte(4);
        break;
      case MessageType.rahn_kardan:
        writer.writeByte(5);
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
