import 'package:amlak_client/db/entity/account.dart';
import 'package:hive/hive.dart';

class AccountDao {
  Future<Box<Account>> _open() async {
    return await Hive.openBox<Account>("account");
  }

  saveAccount(Account account) async {
    var box = await _open();
    box.put("account", account);
  }

  Future<Account?> getAccount() async {
    try{
      var box = await _open();
      return box.get("account");
    }catch(e){
      return null;
    }

  }
}
