import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:card_swiper/card_swiper.dart';
import 'dart:io';

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
        title: Text("نمایش آگهی"),
      ),
      body: Column(
        children: [
          FutureBuilder<List<model.File>?>(
              future: _messageRepo.getMessageFile(widget.message.fileUuid!),
              builder: (c, snap) {
                if (snap.hasData &&
                    snap.data != null &&
                    snap.data!.isNotEmpty) {
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
                              height: MediaQuery.of(context).size.height *
                                  1 /
                                  2.toDouble(),
                              width: 300,
                              child: Swiper(
                                controller: _swiperController,
                                itemCount: snap.data!.length,
                                index: _current,
                                onIndexChanged: (i) {
                                  setState(() {
                                    _current = i;
                                  });
                                },
                                itemBuilder: (c, index) {
                                  return Image.file(
                                      File(snap.data![index].path));
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: snap.data!.map(
                                  (image) {
                                    int index = snap.data!.indexOf(image);
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
                } else {
                  return SizedBox.shrink();
                }
              }),
          Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.message.location,
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            ":موقعیت مکانی",
                            style: TextStyle(color: Colors.cyan),
                          ),
                          SizedBox(
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
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            ": متراژ",
                            style: TextStyle(color: Colors.cyan),
                          ),
                          SizedBox(
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
          SizedBox(height: 40,),
          TextButton(
              onPressed: () {},
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    "تماس",style: TextStyle(fontSize: 30),
                  )))
        ],
      ),
    );
  }
}
