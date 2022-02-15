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
        title: Text("نشان شده ها"),
      ),
      body: FutureBuilder<List<Message>?>(
        future: _messageDao.getPinnedMessage(),
        builder: (c, d) {
          if(d.hasData && d.data!= null && d.data!.isNotEmpty) {
            return Expanded(
              child: ListView.builder(shrinkWrap: true,itemBuilder: (c, index) {
              return buildMessageWidget(d.data![index]);
          }),
            );
          }else{
            return Center(child: Text("شما هیچ آگهی نشان شده ندارید."));
          }
        },
      ),
    );
  }
  Widget buildMessageWidget(Message message) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) {
          return MessagePage(message);
        }));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 15),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                    icon: Icon(message.isPined
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark),
                    onPressed: () {
                      _messageDao
                          .saveMessage(message..isPined = !message.isPined);
                      setState(() {});
                    },
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (message.messageType == MessageType.Req)
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.wallpaper_sharp,
                        size: 100,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: getImage(message.fileUuid!),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Center(
                            child: Text(
                              message.caption,
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                              maxLines: 15,
                            ),
                          ),
                        ),
                        Text(message.location),
                        Row(
                          children: [
                            Text("تومان"),
                            Text(message.value.toString()),
                          ],
                        ),
                        Text(DateTime.fromMillisecondsSinceEpoch(message.time)
                            .toString())
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget getImage(String messageId) {
    return SizedBox(
      height: 120,
      child: FutureBuilder<List<model.File>?>(
          future: _messageRepo.getMessageFile(messageId),
          builder: (c, file) {
            if (file.hasData && file.data != null && file.data!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(file.data![0].path),
                ),
              );
            } else {
              return const Icon(
                Icons.wallpaper_sharp,
                size: 100,
              );
            }
          }),
    );
  }
}
