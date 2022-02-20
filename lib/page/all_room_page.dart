import 'dart:io';

import 'package:Amlak/db/dao/messageDao.dart';
import 'package:Amlak/db/dao/roomDao.dart';
import 'package:Amlak/db/entity/message.dart';
import 'package:Amlak/db/entity/room.dart';
import 'package:Amlak/page/chat_page.dart';
import 'package:Amlak/repo/messageRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:Amlak/db/entity/file.dart' as model;

class AllRoomPage extends StatelessWidget {
  final _roomDao = GetIt.I.get<RoomDao>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  AllRoomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("چت ها"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Room>?>(
          future: _roomDao.getAllRooms(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (c, index) {
                    return FutureBuilder<Message?>(
                        future: _messageDao
                            .getMessage(snapshot.data![index].messageId),
                        builder: (c, msg) {
                          if (msg.hasData && msg.data != null) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (c) {
                                  return ChatPage(snapshot.data![index]);
                                }));
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Row(

                                    children: [
                                      getImage(msg.data!.fileUuid!),
                                      SizedBox(width: 80,),
                                      Text(
                                        snapshot.data![index].lastMessage,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  )),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        });
                  });
            }
            return const Center(child: Text("شما گفتگویی ندارید"));
          }),
    );
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
      height: 110,
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
              return const Image(image: AssetImage('assets/ic_launcher.png'));
            }
          }),
    );
  }
}
