import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User  {
  @HiveField(0)
  String name;

  @HiveField(1)
  int phonenumber;

  @HiveField(2)
  String uuid;

  User(this.uuid, this.name, this.phonenumber);
}
