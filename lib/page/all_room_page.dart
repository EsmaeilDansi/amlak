import 'package:Amlak/db/dao/messageDao.dart';
import 'package:Amlak/db/dao/roomDao.dart';
import 'package:Amlak/db/entity/message.dart';
import 'package:Amlak/db/entity/room.dart';
import 'package:Amlak/page/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllRoomPage extends StatelessWidget {
  final _roomDao = GetIt.I.get<RoomDao>();
  final _messageDao = GetIt.I.get<MessageDao>();

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
              return ListView.builder(shrinkWrap: true,itemCount: snapshot.data!.length,itemBuilder: (c, index) {
                return FutureBuilder<Message?>(
                    future: _messageDao
                        .getMessage(snapshot.data![index].messageId),
                    builder: (c, msg) {
                      if (msg.hasData && msg.data != null) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (c) {
                              return ChatPage(
                                  msg.data!, snapshot.data![index].from);
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
                              child: Text(
                                msg.data!.caption,
                                style: const TextStyle(fontSize: 25),
                              )),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    });
              });
            }
            return Center(child: const Text("شما گفتگویی ندارید"));
          }),
    );
  }
}
