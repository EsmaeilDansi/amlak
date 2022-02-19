import 'package:Amlak/db/entity/message.dart';
import 'package:Amlak/repo/messageRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:Amlak/db/dao/messageDao.dart';
import 'package:Amlak/db/entity/file.dart' as model;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import 'message_page.dart';

class MessageWidget extends StatefulWidget {
  final Message message;
  final bool deleteable;
  final Function? delete;

  const MessageWidget(
      {Key? key, required this.message, this.deleteable = false, this.delete})
      : super(key: key);

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _messageDao = GetIt.I.get<MessageDao>();

  @override
  Widget build(BuildContext context) {
    return buildMessageWidget(widget.message);
  }

  Widget getImage(String messageId) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      height: 130,
      child: FutureBuilder<List<model.File>?>(
          future: _messageRepo.getMessageFile(messageId),
          builder: (c, file) {
            if (file.hasData && file.data != null && file.data!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(file.data!.first.path),
                ),
              );
            } else {
              // setState(() {});
              return const Image(image: AssetImage('assets/ic_launcher.png'));
            }
          }),
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
              width: 4,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 10, right: 0),
                  child: IconButton(
                    icon: widget.deleteable
                        ? const Icon(CupertinoIcons.delete_solid)
                        : Icon(message.isPined
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark),
                    onPressed: () async {
                      if (widget.deleteable) {
                        widget.delete!();
                      } else {
                        _messageDao
                            .saveMessage(message..isPined = !message.isPined);
                      }

                      setState(() {});
                    },
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: getImage(message.fileUuid!),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            message.location,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: Colors.deepOrangeAccent,
                                fontSize: 13),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              "تومان",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 13),
                            ),
                            Text(
                              message.value.toString(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                ":قیمت",
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "مترمربع",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 13),
                            ),
                            Text(
                              message.measure.toString(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                ":متراژ",
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                            )
                          ],
                        ),
                        Text(
                          DateTime.fromMillisecondsSinceEpoch(message.time)
                              .toString()
                              .substring(0, 19),
                          style:
                              const TextStyle(color: Colors.deepOrangeAccent),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: SizedBox(
                    height: Platform.isAndroid ? 70 : 100,
                    child: Text(
                      message.caption,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.amber,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
