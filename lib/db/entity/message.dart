import 'package:amlak_client/db/entity/message_type.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 2)
class Message {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String owner_id;

  @HiveField(2)
  int time;

  @HiveField(3)
  String caption;

  @HiveField(4)
  String location;

  @HiveField(5)
  int value;

  @HiveField(6)
  MessageType messageType;

  @HiveField(7)
  String? fileUuid;

  @HiveField(8)
  int measure;

  @HiveField(9)
  bool isPined;

  @HiveField(10)
  int ownerPhoneNumber;

  Message(
      {required this.value,
      this.id,
      this.fileUuid,
      required this.owner_id,
      required this.time,
      required this.caption,
      required this.measure,
      required this.isPined,
      required this.messageType,
      required this.ownerPhoneNumber,
      required this.location});
}
