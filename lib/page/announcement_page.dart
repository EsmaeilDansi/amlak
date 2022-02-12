import 'dart:io';

import 'package:amlak_client/db/dao/messageDao.dart';
import 'package:amlak_client/db/entity/file.dart' as model;
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:amlak_client/repo/userRepo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AnnouncementPage extends StatefulWidget {
  AnnouncementPage({Key? key}) : super(key: key);

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _messageDao = GetIt.I.get<MessageDao>();
  @override
  void initState() {
    _messageRepo.fetchMessage();
    super.initState();

  }
  final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("همه آگهی ها"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
                decoration: InputDecoration(
              labelText: "search",
              suffixIcon: IconButton(
                  icon: Icon(CupertinoIcons.search), onPressed: () {}),
              border: OutlineInputBorder(),
            )),
          ),
          Expanded(
            child: StreamBuilder<List<Message>>(
                stream: _messageDao.getAllMessage(),
                builder: (context, msgSnapShot) {
                  if (msgSnapShot.hasData && msgSnapShot.data != null) {
                    return ListView.separated(
                      itemCount: msgSnapShot.data!.length,
                      itemBuilder: (c, index) {
                        return buildMessageWidget(msgSnapShot.data![index]);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(
                          color: Colors.blue,
                        );
                      },
                    );
                  } else {
                    return Text(
                      "آگهی ای وجود نداد!",
                      style: TextStyle(color: Colors.blue, fontSize: 17),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }

  Widget getImage(String messageId) {
    return FutureBuilder<List<model.File>?>(
        future: _messageRepo.getMessageFile(messageId),
        builder: (c, file) {
          if (file.hasData && file.data != null && file.data!.isNotEmpty) {
            return Image.file(
              File(file.data![0].path),
              width: 100,
              height: 100,
            );
          } else {
            return Icon(
              Icons.wallpaper_sharp,
              size: 100,
            );
          }
        });
  }

  Widget buildMessageWidget(Message message) {
    return Container(
      height: 102,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (message.messageType == MessageType.Req)
            const Icon(
              Icons.wallpaper_sharp,
              size: 100,
            )
          else
            getImage(message.fileUuid!),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Text(message.caption),
                Text(message.location),
                Text(DateTime.fromMillisecondsSinceEpoch(message.time)
                    .toString())
              ],
            ),
          )
        ],
      ),
    );
  }
}
