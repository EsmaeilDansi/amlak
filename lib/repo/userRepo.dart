

import 'package:amlak_client/db/dao/accountDao.dart';
import 'package:amlak_client/db/entity/account.dart';
import 'package:get_it/get_it.dart';


class UserRepo {
  final _accountDao = GetIt.I.get<AccountDao>();

  Future<bool> loginUser(int  phoneNumber) async {
    _accountDao.saveAccount(Account(phoneNumber));
    return true;

  }
}
