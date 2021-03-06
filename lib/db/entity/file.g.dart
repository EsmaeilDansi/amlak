// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileAdapter extends TypeAdapter<File> {
  @override
  final int typeId = 3;

  @override
  File read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return File(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, File obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.messageId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
