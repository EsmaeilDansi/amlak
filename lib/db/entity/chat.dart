import 'package:hive/hive.dart';


part 'chat.g.dart';

@HiveType(typeId: 6)
class Chat {
  @HiveField(0)
  String id;

  @HiveField(1)
  String from;

  @HiveField(2)
  int time;

  @HiveField(3)
  String content;

  @HiveField(4)
  String messageId;

  @HiveField(9)
  String to;

  Chat({required this.id,required this.from,required this.time,required this.content,required this.to,required this.messageId});
}
