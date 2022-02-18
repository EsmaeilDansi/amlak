import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:card_swiper/card_swiper.dart';
import 'dart:io';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:amlak_client/db/dao/messageDao.dart';
import 'package:amlak_client/db/entity/file.dart' as model;

class MessagePage extends StatefulWidget {
  Message message;

  MessagePage(this.message, {Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int _current = 0;
  var _messageRepo = GetIt.I.get<MessageRepo>();
  final SwiperController _swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("نمایش آگهی"),backgroundColor: Colors.deepPurple
      ),
      body: Column(
        children: [
          FutureBuilder<List<model.File>?>(
              future: _messageRepo.getMessageFile(widget.message.fileUuid!),
              builder: (c, snap) {
                if (snap.hasData &&
                    snap.data != null &&
                    snap.data!.isNotEmpty) {
                  return buildImageView(context, snap.data!);
                } else {
                  return const SizedBox(
                    height: 200,
                    child: Image(image: AssetImage('assets/ic_launcher.png')),
                  );
                }
              }),
          Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: TextField(
                            readOnly: true,
                            enabled: false,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                            ),
                            maxLines: 9,
                            minLines: 1,
                            controller: TextEditingController(
                                text: widget.message.caption),
                          )),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            ":توضیحات",
                            style: TextStyle(
                              color: Colors.cyan,
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          )
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.message.location,
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            ":موقعیت مکانی",
                            style: TextStyle(color: Colors.cyan),
                          ),
                          const SizedBox(
                            width: 40,
                          )
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.message.measure.toString(),
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            ": متراژ",
                            style: TextStyle(color: Colors.cyan),
                          ),
                          const SizedBox(
                            width: 40,
                          )
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.message.value.toString(),
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            ":قیمت ",
                            style: TextStyle(color: Colors.cyan),
                          ),
                          SizedBox(
                            width: 40,
                          )
                        ],
                      ),
                    ],
                  ))),
          SizedBox(
            height: 40,
          ),
          if (Platform.isAndroid)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: TextButton(
                      onPressed: () {
                        TextEditingController controller =
                            TextEditingController();
                        showDialog(
                            context: context,
                            builder: (c) {
                              return AlertDialog(
                                title: Center(child: Text("ارسال پیام")),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelStyle: TextStyle(
                                              color: Colors.deepPurple),
                                          labelText: "پیام را وارد کنید"),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          _sendSMS(controller.text, [
                                            "0${widget.message.ownerPhoneNumber}"
                                          ]);
                                        },
                                        child: Text("ارسال"))
                                  ],
                                ),
                              );
                            });
                      },
                      child: Text("ارسال پیام ")),
                ),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: TextButton(
                      child: Text("تماس"),
                      onPressed: () async {
                        await launch(
                            "tel://0${widget.message.ownerPhoneNumber}");
                      },
                    ))
              ],
            )
          else
            Center(
              child: TextButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (c) {
                          return AlertDialog(
                            title: Text("مشاهده شماره تماس"),
                            content:
                                Text("0${widget.message.ownerPhoneNumber}"),
                          );
                        });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        "مشاهده شماره تماس",
                        style: TextStyle(fontSize: 30),
                      ))),
            )
        ],
      ),
    );
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  Widget buildImageView(BuildContext context, List<model.File> files) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (Platform.isWindows)
          IconButton(
              onPressed: () {
                _swiperController.previous();
              },
              icon: const Icon(CupertinoIcons.back)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 1 / 3.toDouble(),
                width: 300,
                child: Swiper(
                  controller: _swiperController,
                  itemCount: files.length,
                  index: _current,
                  onIndexChanged: (i) {
                    setState(() {
                      _current = i;
                    });
                  },
                  itemBuilder: (c, index) {
                    return GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (c) {
                                return AlertDialog(
                                  content: Image.file(File(files[index].path)),
                                );
                              });
                        },
                        child: Image.file(File(files[index].path)));
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: files.map(
                    (image) {
                      int index = files.indexOf(image);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current == index
                                ? Color.fromRGBO(0, 0, 0, 0.9)
                                : Color.fromRGBO(0, 0, 0, 0.4)),
                      );
                    },
                  ).toList(), // this was the part the I had to add
                ),
              ),
            ],
          ),
        ),
        if (Platform.isWindows)
          IconButton(
              onPressed: () {
                _swiperController.next();
              },
              icon: const Icon(CupertinoIcons.chevron_right))
      ],
    );
  }
}
