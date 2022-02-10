import 'package:amlak_client/db/entity/user.dart';

import 'package:hive/hive.dart';

class UserDao {
  Future<Box<User>> _open() async {
    return await Hive.openBox<User>("user");
  }

  addUser(User user) async {
    var box = await _open();
    box.put(user.uuid, user);
  }

  Future<User?> getUser(String uuid) async {
    var box = await _open();
    return box.values.firstWhere((element) => element.uuid == uuid);
  }

  Future<List<User>?> getAllUser(String uuid) async {
    var box = await _open();
    return box.values.toList();
  }
}
