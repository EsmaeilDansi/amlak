import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("همه آگهی ها"),
      ),
      body: Column(
        children: [
          TextField(
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
