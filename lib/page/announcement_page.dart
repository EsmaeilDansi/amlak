import 'dart:io';

import 'package:amlak_client/db/dao/messageDao.dart';
import 'package:amlak_client/db/entity/file.dart' as model;
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/page/message_page.dart';
import 'package:amlak_client/page/message_widget.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:amlak_client/services/locationServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _messageDao = GetIt.I.get<MessageDao>();

  @override
  void initState() {
    _messageRepo.fetchMessage();
    _loadLocation();
    super.initState();
  }

  _loadLocation() async {
    _currentLocation.add((await _locationServices.getProvince())[7].name);
    _provinces = await _locationServices.getProvince();
  }

  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _locationServices = GetIt.I.get<LocationServices>();
  final BehaviorSubject<String> _currentLocation = BehaviorSubject.seeded("");

  final BehaviorSubject<List<Message>> _messages = BehaviorSubject.seeded([]);
  final BehaviorSubject<String> _searchState = BehaviorSubject.seeded("");

  final _desController = TextEditingController();
  final _minValueController = TextEditingController();
  final _maxValueController = TextEditingController();
  final BehaviorSubject<String> _locationSubject = BehaviorSubject.seeded("");
  List<Province> _provinces = [];

  final BehaviorSubject<bool> _search = BehaviorSubject.seeded(false);
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 10, top: 8, bottom: 8),
            child: StreamBuilder<String>(
                stream: _searchState.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            snapshot.data!,
                            style: const TextStyle(
                                color: Colors.deepPurple, fontSize: 15),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          IconButton(
                              icon: const Icon(
                                CupertinoIcons.clear,
                                color: Colors.cyanAccent,
                              ),
                              onPressed: () async {
                                _searchState.add("");
                                setState(() {});
                              })
                        ],
                      ),
                    );
                  } else {
                    return Row(
                      children: [
                        StreamBuilder<String>(
                            stream: _currentLocation.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Text(
                                  snapshot.data!,
                                  style: const TextStyle(
                                      color: Colors.amber, fontSize: 15),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (c) {
                                    return AlertDialog(
                                        content: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              200,
                                      width: 150,
                                      child: Column(
                                        children: [
                                          StreamBuilder<String>(
                                              stream: _currentLocation.stream,
                                              builder: (c, s) {
                                                if (s.hasData &&
                                                    s.data != null) {
                                                  return Text(s.data!);
                                                }
                                                return const SizedBox.shrink();
                                              }),
                                          Expanded(
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemBuilder: (c, index) {
                                                  List<String> ci = [];
                                                  ci.add(
                                                      _provinces[index].name);
                                                  ci.addAll(_locationServices
                                                      .getCityOfProvince(
                                                          _provinces[index].id)
                                                      .map((e) =>
                                                          _provinces[index]
                                                              .name +
                                                          "_" +
                                                          e.name));
                                                  return GestureDetector(
                                                    onTap: () {
                                                      _currentLocation
                                                          .add(ci[0]);
                                                      Navigator.pop(context);
                                                    },
                                                    child:
                                                        DropdownButton<String>(
                                                      value: ci[0],
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down_outlined),
                                                      iconSize: 24,
                                                      elevation: 1,
                                                      style: const TextStyle(
                                                          color: Colors
                                                              .deepPurple),
                                                      underline: Container(
                                                        height: 2,
                                                        color: Colors
                                                            .deepPurpleAccent,
                                                      ),
                                                      onChanged: (newValue) {},
                                                      items: ci.map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child:
                                                              GestureDetector(
                                                            child: Text(value),
                                                            onTap: () {
                                                              _currentLocation
                                                                  .add(value);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  );
                                                },
                                                itemCount: _provinces.length),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: Text("جستجو"))
                                        ],
                                      ),
                                    ));
                                  });
                            },
                            icon: const Icon(
                              CupertinoIcons.location,
                              color: Colors.deepPurple,
                              size: 15,
                            )),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: (str) {
                              if (str.isEmpty) {
                                _search.add(false);
                                setState(() {});
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "جستجو بر اساس توضیحات آگهی",
                              hintStyle: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 12,
                              ),
                              suffixIcon: StreamBuilder<bool>(
                                  stream: _search.stream,
                                  builder: (context, snapshot) {
                                    return IconButton(
                                        icon: Icon(
                                          snapshot.hasData && snapshot.data!
                                              ? CupertinoIcons.clear
                                              : CupertinoIcons.search,
                                          color: Colors.cyanAccent,
                                        ),
                                        onPressed: () async {
                                          if (_search.stream.value) {
                                            setState(() {});
                                            _desController.clear();
                                            _search.add(false);
                                          } else if (_desController
                                              .text.isNotEmpty) {
                                            var msg = _messages.value.where(
                                                (element) => element.caption
                                                    .contains(
                                                        _desController.text));
                                            _messages.add(msg.toList());
                                            _search.add(true);
                                          }
                                        });
                                  }),
                            ),
                            controller: _desController,
                          ),
                        ),
                      ],
                    );
                  }
                }),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 20, bottom: 5, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (Platform.isWindows)
                  IconButton(
                      onPressed: () {
                        _messageRepo.fetchMessage();
                      },
                      icon: Icon(
                        CupertinoIcons.arrow_counterclockwise_circle,
                        color: Colors.deepPurple,
                        size: 35,
                      )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: StreamBuilder<String>(
                          stream: _locationSubject.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: DropdownButton(
                                    icon: const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child:
                                          Icon(Icons.arrow_drop_down_outlined),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    value: snapshot.data,
                                    items: <DropdownMenuItem<String>>[
                                      const DropdownMenuItem(
                                        child: Text(
                                          "همه آگهی ها",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        value: "",
                                      ),
                                      DropdownMenuItem(
                                        child: const Text(
                                          "فروش",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        value: MessageType.forosh.name,
                                      ),
                                      DropdownMenuItem(
                                        child: const Text(
                                          "خرید ",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        value: MessageType.kharid.name,
                                      ),
                                      DropdownMenuItem(
                                        child: const Text(
                                          "رهن کردن ",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        value: MessageType.rahn_kardan.name,
                                      ),
                                      DropdownMenuItem(
                                        child: const Text(
                                          "رهن دادن ",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        value: MessageType.rahn_dadan.name,
                                      ),
                                      DropdownMenuItem(
                                        child: const Text(
                                          "اجاره کردن ",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        value: MessageType.ajara_kardan.name,
                                      ),
                                      DropdownMenuItem(
                                        child: const Text(
                                          "اجاره دادن ",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        value: MessageType.ajara_dadan.name,
                                      ),
                                    ],
                                    onChanged: (value) {
                                      _locationSubject.add(value.toString());
                                    }),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                    ),
                  ],
                ),
                Container(
                    width: Platform.isAndroid ? null : 150,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (c) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "تعیین محدوده متراژ",
                                        style:
                                            TextStyle(color: Colors.deepPurple),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              controller: _maxValueController,
                                              decoration: const InputDecoration(
                                                  labelText: "حداکثرمتراژ",
                                                  border: OutlineInputBorder(),
                                                  labelStyle: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.cyanAccent)),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: TextField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              controller: _minValueController,
                                              decoration: const InputDecoration(
                                                  labelText: "حداقل متراژ",
                                                  border: OutlineInputBorder(),
                                                  labelStyle: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.cyanAccent)),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: TextButton(
                                            onPressed: () async {
                                              int min = int.parse(
                                                  _minValueController
                                                          .text.isNotEmpty
                                                      ? _minValueController.text
                                                      : "0");
                                              int max = int.parse(
                                                  _maxValueController
                                                          .text.isNotEmpty
                                                      ? _minValueController.text
                                                      : "1000000000000000000");
                                              var msg = _messages.value
                                                  .where((element) =>
                                                      min <= element.measure &&
                                                      element.measure <= max)
                                                  .toList();
                                              _messages.add(msg);
                                              _searchState.add(
                                                  "نتیجه جستجو براساس محدودسازی متراژ");
                                              _minValueController.clear();
                                              _maxValueController.clear();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("جستجو")),
                                      )
                                    ],
                                  ),
                                );
                              });
                        },
                        child: const Text("تعیین متراژ"))),
                Container(
                    width: Platform.isAndroid ? null : 150,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (c) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "تعیین محدوده قیمت",
                                        style:
                                            TextStyle(color: Colors.deepPurple),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              controller: _maxValueController,
                                              decoration: const InputDecoration(
                                                  labelText: "حداکثر قیمت",
                                                  border: OutlineInputBorder(),
                                                  labelStyle: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.cyanAccent)),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: TextField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              controller: _minValueController,
                                              decoration: const InputDecoration(
                                                  labelText: "حداقل قیمت",
                                                  border: OutlineInputBorder(),
                                                  labelStyle: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.cyanAccent)),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: TextButton(
                                            onPressed: () async {
                                              int min = int.parse(
                                                  _minValueController
                                                          .text.isNotEmpty
                                                      ? _minValueController.text
                                                      : "0");
                                              int max = int.parse(
                                                  _maxValueController
                                                          .text.isNotEmpty
                                                      ? _minValueController.text
                                                      : "1000000000000000000");
                                              var msg = _messages.value
                                                  .where((element) =>
                                                      min <= element.value &&
                                                      element.value <= max)
                                                  .toList();
                                              _messages.add(msg);
                                              _searchState.add(
                                                  "نتیجه جستجو براساس محدودسازی قیمت");
                                              _maxValueController.clear();
                                              _minValueController.clear();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("جستجو")),
                                      )
                                    ],
                                  ),
                                );
                              });
                        },
                        child: const Text("تعیین قیمت"))),
              ],
            ),
          ),
          Divider(),
          Expanded(
              child: StreamBuilder<String>(
            stream: _currentLocation.stream,
            builder: (c, snap) {
              if (snap.hasData && snap.data != null) {
                return StreamBuilder<String?>(
                    stream: _locationSubject.stream,
                    builder: (c, msgType) {
                      if (msgType.hasData && msgType.data != null) {
                        return StreamBuilder<List<Message>>(
                            stream: _messageDao.getAllMessageByLocationAndType(
                                snap.data!, msgType.data!),
                            builder: (context, msgSnapShot) {
                              if (msgSnapShot.hasData &&
                                  msgSnapShot.data != null) {
                                _messages.add(msgSnapShot.data!);
                                return StreamBuilder<List<Message>>(
                                    stream: _messages.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null &&
                                          snapshot.data!.isNotEmpty) {
                                        return SmartRefresher(
                                            controller: _refreshController,
                                            enablePullDown: true,
                                            enablePullUp: false,
                                            header: WaterDropHeader(),
                                            footer: CustomFooter(
                                              builder: (BuildContext context,
                                                  LoadStatus? mode) {
                                                Widget body;
                                                if (mode == LoadStatus.idle) {
                                                  body = Text("pull up load");
                                                } else if (mode ==
                                                    LoadStatus.loading) {
                                                  body =
                                                      CupertinoActivityIndicator();
                                                } else if (mode ==
                                                    LoadStatus.failed) {
                                                  body = Text(
                                                      "Load Failed!Click retry!");
                                                } else if (mode ==
                                                    LoadStatus.canLoading) {
                                                  body = Text(
                                                      "release to load more");
                                                } else {
                                                  body = Text("No more Data");
                                                }
                                                return Container(
                                                  height: 55.0,
                                                  child: Center(child: body),
                                                );
                                              },
                                            ),
                                            onRefresh: () {
                                              _messageRepo.fetchMessage();
                                              _refreshController
                                                  .refreshCompleted();
                                            },
                                            child: GridView.builder(
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (c, index) {
                                                return MessageWidget(
                                                    message:
                                                        snapshot.data![index]);
                                              },
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    Platform.isAndroid
                                                        ? 1
                                                        : MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                600
                                                            ? 1
                                                            : 2,
                                                crossAxisSpacing: 8,
                                                mainAxisSpacing: 8,
                                                childAspectRatio: (2 / 1),
                                              ),
                                            ));
                                      } else {
                                        return const Center(
                                          child: Text(
                                            "!آگهی ای وجود نداد",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 17),
                                          ),
                                        );
                                      }
                                    });
                              } else {
                                return const Center(
                                  child: Text(
                                    "آگهی ای وجود نداد!",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 17),
                                  ),
                                );
                              }
                            });
                      }
                      return const Center(child: Text("آگهی وجود ندارد."));
                    });
              }
              return const Center(child: Text("آگهی وجود ندارد."));
            },
          ))
        ],
      ),
    );
  }
}
