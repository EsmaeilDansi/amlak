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
  String packId;

  Message(
      {required this.value,
      this.id,
      required this.packId,
      required this.owner_id,
      required this.time,
      required this.caption,
      required this.messageType,
      required this.location});
}
