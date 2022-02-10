import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 5)
class Account {
  @HiveField(0)
  String phoneNumber;

  @HiveField(2)
  String uuid;

  Account(this.phoneNumber, this.uuid);
}
