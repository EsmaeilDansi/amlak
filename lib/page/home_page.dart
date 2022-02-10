import 'package:amlak_client/page/announcement_page.dart';
import 'package:amlak_client/page/my_page.dart';
import 'package:amlak_client/page/new_msg_page.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/subjects.dart';

enum page { announcementPage, addMessage, myPage }

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final BehaviorSubject<page> _pageSubject =
      BehaviorSubject.seeded(page.announcementPage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _pageSubject.add(page.myPage),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                      Icons.article_outlined,
                      color: Colors.blue,
                    ),
                    Text("آگهی های  من")
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _pageSubject.add(page.addMessage),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                      Icons.add,
                      color: Colors.blue,
                    ),
                    Text(" ثبت آگهی جدید")
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _pageSubject.add(page.announcementPage),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                      Icons.assignment_outlined,
                      color: Colors.blue,
                    ),
                    Text("همه آگهی ها")
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: StreamBuilder<page>(
          stream: _pageSubject.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox.shrink();
            }
            if (snapshot.data == page.announcementPage) {
              return const AnnouncementPage();
            } else if (snapshot.data == page.addMessage) {
              return const NewMessagePage();
            } else if (snapshot.data == page.myPage) {
              return MyPage();
            } else {
              return Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text("آگهی ای وجود ندارد."),
                  ],
                ),
              );
            }
          }),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
