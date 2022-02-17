import 'package:amlak_client/db/dao/accountDao.dart';
import 'package:amlak_client/db/entity/account.dart';
import 'package:amlak_client/page/pinnedPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class MyPage extends StatefulWidget {
  MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _accountDao = GetIt.I.get<AccountDao>();
  final _textController = TextEditingController();

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
                                  title: const Text(
                                    "ثبت نام",
                                    style: TextStyle(
                                        color: Colors.deepPurple, fontSize: 28),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                          maxLength: 11,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          controller: _textController,
                                          decoration: const InputDecoration(
                                              suffixIcon: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 20, left: 25),
                                                child: Text(
                                                  "*",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              border: OutlineInputBorder(),
                                              hintText: "09121234567",
                                              labelStyle: TextStyle(
                                                  color: Colors.cyanAccent),
                                              labelText: "شماره تلفن")),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextButton(
                                            onPressed: () {
                                              if (_textController
                                                      .text.isNotEmpty &&
                                                  _textController.text.length ==
                                                      11) {
                                                _accountDao.saveAccount(Account(
                                                    int.parse(
                                                        _textController.text)));
                                                setState(() {});
                                              }
                                            },
                                            child: const Text("ثبت نام")),
                                      )
                                    ],
                                  ),
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
            padding: const EdgeInsets.only(left: 8, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: const [
                  Icon(
                    CupertinoIcons.bookmark_fill,
                    color: Colors.deepPurple,
                  ),
                  Text("نشان شده ها")
                ]),
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
            padding: const EdgeInsets.only(left: 10, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(
                    CupertinoIcons.doc_plaintext,
                    color: Colors.deepPurple,
                  ),
                  Text("آگهی های من")
                ]),
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
