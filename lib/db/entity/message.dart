import 'package:amlak_client/db/entity/message_type.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 2)
class Message {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String owner_uuid;

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

  Message(
      {required this.value,
      required this.uuid,
      required this.owner_uuid,
      required this.time,
      required this.caption,
      required this.messageType,
      required this.location});
}
