
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:amlak_client/repo/userRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("همه آگهی ها"),
      ),
      body: Column(
        children: [
          GestureDetector(child: Icon(Icons.assignment_outlined),onTap: (){
            Message me = Message(value: 2332, packId: "3434",
                owner_id: "43434", time:4433, caption: "4343", messageType: MessageType.Sale, location: "erer");
            GetIt.I.get<UserRepo>().loginUser("323232");
          },),
          const TextField(
            decoration: InputDecoration(hintText: "search"),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: 300,
                itemBuilder: (c, index) {
                  return Text("tttt");
                }),
          )
        ],
      ),
    );
  }
}
