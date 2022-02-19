import 'package:Amlak/db/dao/accountDao.dart';
import 'package:Amlak/db/dao/chatDao.dart';
import 'package:Amlak/db/entity/account.dart';
import 'package:Amlak/db/entity/chat.dart';
import 'package:Amlak/db/entity/message.dart';
import 'package:Amlak/repo/messageRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  Message message;
  String from;

  ChatPage(this.message, this.from, {Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatDao = GetIt.I.get<ChatDao>();
  final TextEditingController _textEditingController = TextEditingController();
  final MessageRepo _messageRepo = GetIt.I.get<MessageRepo>();
  final _accountDao = GetIt.I.get<AccountDao>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Image(
            image: AssetImage('assets/ic_launcher.png'),
            width: 50,
            height: 50,
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: FutureBuilder<Account?>(
            future: _accountDao.getAccount(),
            builder: (c, ac) {
              if (ac.hasData && ac.data != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StreamBuilder<List<Chat>?>(
                        stream:
                            _chatDao.getChat(widget.message.id!, widget.from),
                        builder: (c, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.isNotEmpty) {
                            return Expanded(
                                child: Container(
                              color: Colors.tealAccent.withOpacity(0.5),
                              child: ListView.builder(
                                  reverse: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (c, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: snapshot
                                                .data![index].from
                                                .contains(ac.data!.phoneNumber
                                                    .toString())
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    snapshot
                                                        .data![index].content,
                                                    style: const TextStyle(
                                                        fontSize: 20),
                                                  ),
                                                  if (snapshot.data![index].from
                                                      .contains(ac
                                                          .data!.phoneNumber
                                                          .toString()))
                                                    Icon(
                                                      CupertinoIcons.checkmark,
                                                    )
                                                ],
                                              )),
                                        ],
                                      ),
                                    );
                                  }),
                            ));
                          } else {
                            return const Text("پیامی وجود ندارد.");
                          }
                        }),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                minLines: 1,
                                maxLines: 3,
                                controller: _textEditingController,
                                decoration:
                                    const InputDecoration(hintText: "پیام"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: IconButton(
                                onPressed: () {
                                  if (_textEditingController.text.isNotEmpty) {
                                    _messageRepo.sendChat(
                                        content: _textEditingController.text,
                                        to: widget.message.owner_id.contains(
                                                ac.data!.phoneNumber.toString())
                                            ? widget.from
                                            : widget.message.owner_id,
                                        messageId: widget.message.id!,
                                        from: ac.data!.phoneNumber.toString());
                                    _textEditingController.clear();
                                  }
                                },
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.blue,
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return SizedBox.shrink();
              }
            }));
  }
}
