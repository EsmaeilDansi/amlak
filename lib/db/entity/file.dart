
import 'package:hive/hive.dart';

part 'file.g.dart';

@HiveType(typeId: 3)
class File{

  @HiveField(0)
  String path;

  @HiveField(1)
  String uuid;

  @HiveField(2)
  String messageId;

  File(this.path, this.uuid, this.messageId);
}