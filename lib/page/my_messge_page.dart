import 'dart:io';

import 'package:amlak_client/db/dao/accountDao.dart';
import 'package:amlak_client/db/dao/messageDao.dart';
import 'package:amlak_client/db/entity/account.dart';
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import 'message_widget.dart';

class MyMessagePage extends StatefulWidget {
  @override
  State<MyMessagePage> createState() => _MyMessagePageState();
}

class _MyMessagePageState extends State<MyMessagePage> {
  var _messageDao = GetIt.I.get<MessageDao>();
  var _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("آگهی های من"),backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<Account?>(
            future: GetIt.I.get<AccountDao>().getAccount(),
            builder: (context, account) {
              if (account.hasData && account.data != null) {
                return FutureBuilder<List<Message>?>(
                  future: _messageDao
                      .getMyMessage(account.data!.phoneNumber.toString()),
                  builder: (c, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      return GridView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (c, index) {
                          return MessageWidget(message: snapshot.data![index],deleteable: true,delete: ()async {
                            var res =
                                await _messageRepo.deleteMessage( snapshot.data![index]);
                            if (res) {
                              setState(() {});
                            } else {
                              FToast fToast = FToast();
                              fToast.init(context);

                              fToast.showToast(
                                child: const Text(
                                  "خطایی رخ داده است",
                                  style: TextStyle(fontSize: 26),
                                ),
                                gravity: ToastGravity.CENTER,
                                toastDuration: const Duration(seconds: 2),
                              );
                            }
                          },);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Platform.isAndroid
                              ? 1
                              : MediaQuery.of(context).size.width < 600
                                  ? 1
                                  : 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: (2 / 1),
                        ),
                      );
                    } else {
                      return const Center(child: Text("پیامی وجود ندارد."));
                    }
                  },
                );
              } else {
                return Center(child: Text("پیامی وجود ندارد."));
              }
            }),
      ),
    );
  }
}
