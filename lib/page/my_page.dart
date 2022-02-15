import 'package:amlak_client/db/dao/accountDao.dart';
import 'package:amlak_client/db/entity/account.dart';
import 'package:amlak_client/page/pinnedPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MyPage extends StatelessWidget {
  MyPage({Key? key}) : super(key: key);

  var _accountDao = GetIt.I.get<AccountDao>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("آگهی های من"),
      ),
      body: Column(
        children: [
          FutureBuilder<Account?>(
              future: _accountDao.getAccount(),
              builder: (c, s) {
                if (s.hasData && s.data != null) {
                  return const SizedBox.shrink();
                } else if (!s.hasData &&
                    s.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: GestureDetector(
                        child: const Center(
                            child: Text(
                          "ورود به حساب کاربری",
                          style: TextStyle(color: Colors.blue, fontSize: 17),
                        )),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (c) {
                                return AlertDialog(
                                  content: TextField(
                                    decoration:
                                        buildInputDecoration("شماره تلفن"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("لغو"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        //todo
                                      },
                                      child: const Text("ورود"),
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(Icons.bookmark), Text("نشان شده ها")]),
                IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) {
                        return PinnedPage();
                      }));
                    },
                    icon: Icon(Icons.arrow_forward_ios))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(Icons.storage), Text("آگهی های من")]),
                Icon(Icons.arrow_forward_ios)
              ],
            ),
          )
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(label) {
    return InputDecoration(
        suffixIcon: const Padding(
          padding: EdgeInsets.only(top: 20, left: 25),
          child: Text(
            "*",
            style: TextStyle(color: Colors.red),
          ),
        ),
        labelText: label);
  }
}
