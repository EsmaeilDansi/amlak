// ignore_for_file: constant_identifier_names

import 'package:hive_flutter/hive_flutter.dart';

part 'message_type.g.dart';

@HiveType(typeId: 4)
enum MessageType {
  @HiveField(0)
  ajara_dadan,
  @HiveField(1)
  rahn_dadan,
  @HiveField(2)
  forosh,
  @HiveField(3)
  kharid,
  @HiveField(4)
  ajara_kardan,
  @HiveField(5)
  rahn_kardan
}
