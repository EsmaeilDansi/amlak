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

  Room(
      {required this.from,
      required this.messageId,
      required this.time,
      required this.isReed});
}
