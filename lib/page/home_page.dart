import 'package:amlak_client/page/announcement_page.dart';
import 'package:amlak_client/page/my_messge_page.dart';
import 'package:amlak_client/page/new_msg_page.dart';
import 'package:amlak_client/page/pinnedPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/subjects.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("همه آگهی ها"),backgroundColor: Colors.deepPurple,),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Column(
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(right: 100),
                      child: Image(
                        image: AssetImage('assets/ic_launcher.png'),
                        width: 120,
                        height: 110,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.add,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  'ثبت آگهی جدید',
                  style: _style(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (c) {
                    return const NewMessagePage();
                  }));
                },
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.bookmark_fill,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  'نشان شده ها',
                  style: _style(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (c) {
                    return PinnedPage();
                  }));
                },
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.doc_person,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  'آکهی های من',
                  style: _style(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (c) {
                    return MyMessagePage();
                  }));
                },
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.doc_plaintext,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  'درباره من',
                  style: _style(),
                ),
                onTap: () {
                  // showDialog(
                  //     context: context,
                  //     builder: (c) {
                  //       return const Text("we");
                  //     });
                },
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.checkmark_seal,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  'نسخه 1.0.0',
                  style: _style(),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) {
                      return const NewMessagePage();
                    }));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(
                        CupertinoIcons.add_circled_solid,
                        color: Colors.deepPurple,
                        size: 30,
                      ),
                      Text(" ثبت آگهی جدید")
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: const AnnouncementPage()
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  TextStyle _style() {
    return TextStyle(color: Colors.black, fontSize: 16);
  }
}
