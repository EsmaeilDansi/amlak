import 'package:hive/hive.dart';

part 'room.g.dart';

@HiveType(typeId: 7)
class Room {
  @HiveField(0)
  String messageId;

  @HiveField(1)
  String from;

  @HiveField(2)
  int time;

  @HiveField(3)
  bool isReed;

  @HiveField(4)
  String ownerId;

  @HiveField(5)
  String to;

  @HiveField(6)
  String lastMessage;

  Room(
      {required this.from,
      required this.messageId,
      required this.time,
      required this.lastMessage,
      required this.ownerId,
      required this.isReed,
      required this.to});
}
