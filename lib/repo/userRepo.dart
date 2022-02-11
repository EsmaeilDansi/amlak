import 'dart:convert';

import 'package:amlak_client/db/dao/accountDao.dart';
import 'package:amlak_client/db/entity/account.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

class UserRepo {
  final _accountDao = GetIt.I.get<AccountDao>();

  Future<bool> loginUser(String phoneNumber) async {
    try{
      var res = await post(
        Uri.parse("$BASE_URI/login/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, String>{'id': '0', 'phoneNumber': phoneNumber.toString()}),
      );

      _accountDao.saveAccount(Account(phoneNumber, res.body));
      return true;
    }catch(e){
      return false;
    }

  }
}
