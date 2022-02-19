import 'dart:io';

import 'package:Amlak/db/dao/accountDao.dart';
import 'package:Amlak/db/dao/messageDao.dart';
import 'package:Amlak/db/entity/account.dart';
import 'package:Amlak/db/entity/message.dart';
import 'package:Amlak/repo/messageRepo.dart';
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
  final _messageDao = GetIt.I.get<MessageDao>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("آگهی های من"),backgroundColor: Colors.deepPurple,
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
                return const Center(child: Text("پیامی وجود ندارد."));
              }
            }),
      ),
    );
  }
}
