import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 5)
class Account {
  @HiveField(0)
  int phoneNumber;
  Account(this.phoneNumber);
}
