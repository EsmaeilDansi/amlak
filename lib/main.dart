import 'package:amlak_client/db/dao/userDao.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/db/entity/user.dart';
import 'package:amlak_client/page/home_page.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:amlak_client/repo/userRepo.dart';
import 'package:amlak_client/services/locationServices.dart';
import 'package:amlak_client/services/permissionServices.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import 'db/dao/accountDao.dart';
import 'db/dao/fileDao.dart';
import 'db/dao/messageDao.dart';
import 'db/entity/account.dart';
import 'db/entity/file.dart';
import 'db/entity/message.dart';

void main() {
  _initDb();

}

_initDb() async {
  await Hive.initFlutter("db");
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FileAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(AccountAdapter());
  GetIt.I.registerSingleton<UserDao>(UserDao());
  GetIt.I.registerSingleton<FileDao>(FileDao());
  GetIt.I.registerSingleton<MessageDao>(MessageDao());
  GetIt.I.registerSingleton<AccountDao>(AccountDao());
  GetIt.I.registerSingleton<UserRepo>(UserRepo());
  GetIt.I.registerSingleton<MessageRepo>(MessageRepo());
  GetIt.I.registerSingleton<PermissionServices>(PermissionServices());
  GetIt.I.registerSingleton<LocationServices>(LocationServices());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: HomePage(),
      ),
    );
  }
}
