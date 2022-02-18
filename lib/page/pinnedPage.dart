import 'dart:io';

import 'package:amlak_client/db/dao/messageDao.dart';
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:amlak_client/db/entity/file.dart' as model;

import 'message_page.dart';
import 'message_widget.dart';

class PinnedPage extends StatefulWidget {
  @override
  State<PinnedPage> createState() => _PinnedPageState();
}

class _PinnedPageState extends State<PinnedPage> {
  var _messageDao = GetIt.I.get<MessageDao>();
  var _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("نشان شده ها"),backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Message>?>(
          future: _messageDao.getPinnedMessage(),
          builder: (c, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              return GridView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (c, index) {
                  return MessageWidget(message: snapshot.data![index]);
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
              return const Center(child: Text("شما هیچ آگهی نشان شده ندارید."));
            }
          },
        ),
      ),
    );
  }
}
