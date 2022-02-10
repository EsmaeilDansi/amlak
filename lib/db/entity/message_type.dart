// ignore_for_file: constant_identifier_names

import 'package:hive_flutter/hive_flutter.dart';

part 'message_type.g.dart';

@HiveType(typeId: 7)
enum MessageType {
  @HiveField(0)
  Req,
  @HiveField(1)
  Sale,
}
