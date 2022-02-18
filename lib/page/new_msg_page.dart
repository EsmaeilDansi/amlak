import 'dart:async';
import 'dart:io';

import 'package:amlak_client/db/dao/accountDao.dart';
import 'package:amlak_client/db/entity/account.dart';
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:amlak_client/services/locationServices.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({Key? key}) : super(key: key);

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  final BehaviorSubject<MessageType> _valueSubject =
      BehaviorSubject.seeded(MessageType.forosh);
  final List<String> _selectedFilePath = [];
  final BehaviorSubject<String> _currentLocation = BehaviorSubject.seeded("");
  final _captionFormKey = GlobalKey<FormState>();
  final _valueFormKey = GlobalKey<FormState>();
  final _measureFormKey = GlobalKey<FormState>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _valueController = TextEditingController();
  final _measureController = TextEditingController();
  final _captionController = TextEditingController();
  final _locationServices = GetIt.I.get<LocationServices>();
  final _provinces = [];
  final _accountDao = GetIt.I.get<AccountDao>();
  final _textController = TextEditingController();

  @override
  void initState() {
    _load();
    super.initState();
  }

  _load() async {
    var res = await _locationServices.getProvince();
    _provinces.addAll(res);
    _currentLocation.add((res[7].name));
    _currentLocation.add(_currentLocation.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ثبت  آگهی ",),backgroundColor: Colors.deepPurple
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: StreamBuilder<MessageType>(
                    stream: _valueSubject.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return DropdownButton(
                            icon: const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Icon(Icons.arrow_drop_down_outlined),
                            ),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            value: snapshot.data,
                            items: const <DropdownMenuItem<MessageType>>[
                              DropdownMenuItem(
                                child: Text(
                                  "فروش",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: MessageType.forosh,
                              ),
                              DropdownMenuItem(
                                child: Text(
                                  "خرید ",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: MessageType.kharid,
                              ),
                              DropdownMenuItem(
                                child: Text(
                                  "رهن کردن ",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: MessageType.rahn_kardan,
                              ),
                              DropdownMenuItem(
                                child: Text(
                                  "رهن دادن ",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: MessageType.rahn_dadan,
                              ),
                              DropdownMenuItem(
                                child: Text(
                                  "اجاره کردن ",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: MessageType.ajara_kardan,
                              ),
                              DropdownMenuItem(
                                child: Text(
                                  "اجاره دادن ",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: MessageType.ajara_dadan,
                              ),
                            ],
                            onChanged: (value) {
                              _valueSubject.add(value as MessageType);
                            });
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Text(
                  "نوع آگهی",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                StreamBuilder<MessageType>(
                    stream: _valueSubject.stream,
                    builder: (c, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        if (snapshot.data == MessageType.ajara_dadan ||
                            snapshot.data == MessageType.forosh ||
                            snapshot.data == MessageType.rahn_dadan) {
                          int w = MediaQuery.of(context).size.width.toInt();
                          return _selectedFilePath.isNotEmpty
                              ? SizedBox(
                                  height:
                                      w > 500 && _selectedFilePath.length > 4 ||
                                              w < 500 &&
                                                  _selectedFilePath.length > 2
                                          ? 200
                                          : 140,
                                  child: picturePage())
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        var res = await FilePicker.platform
                                            .pickFiles(
                                                type: FileType.image,
                                                allowMultiple: true);
                                        if (res != null) {
                                          for (var element in res.files) {
                                            _selectedFilePath
                                                .add(element.path!);
                                          }
                                          setState(() {});
                                        }
                                      },
                                      child: const Icon(
                                        CupertinoIcons.camera_circle,
                                        color: Colors.deepPurple,
                                        size: 90,
                                      ),
                                    ),
                                    Center(child: Text("انتخاب عکس"))
                                  ],
                                );
                        } else {
                          return const SizedBox(
                            width: 200,
                            height: 200,
                            child: Image(
                                image: AssetImage('assets/ic_launcher.png')),
                          );
                        }
                      } else {
                        return const SizedBox(
                          width: 200,
                          height: 200,
                          child: Image(
                              image: AssetImage('assets/ic_launcher.png')),
                        );
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    top: 50,
                    right: 10,
                  ),
                  child: Form(
                    key: _measureFormKey,
                    child: TextFormField(
                      controller: _measureController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "مقادیر درخواستی را وارد کنید";
                        }
                      },
                      decoration: buildInputDecoration("متراژ بر حسب متر مربع"),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 10,
                  ),
                  child: Form(
                    key: _valueFormKey,
                    child: TextFormField(
                      controller: _valueController,
                      decoration: buildInputDecoration("قیمت بر حسب تومان"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "مقادیر درخواستی را وارد کنید";
                        }
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (c) {
                                      return AlertDialog(
                                        content: FutureBuilder<List<Province>>(
                                          future:
                                              _locationServices.getProvince(),
                                          builder:
                                              (BuildContext context, snapshot) {
                                            if (snapshot.hasData &&
                                                snapshot.data != null) {
                                              return SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    200,
                                                width: 150,
                                                child: Column(
                                                  children: [
                                                    StreamBuilder<String>(
                                                        stream: _currentLocation
                                                            .stream,
                                                        builder: (c, s) {
                                                          if (s.hasData &&
                                                              s.data != null) {
                                                            return Text(
                                                                s.data!);
                                                          }
                                                          return const SizedBox
                                                              .shrink();
                                                        }),
                                                    Expanded(
                                                      child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemBuilder:
                                                              (c, index) {
                                                            List<String> ci =
                                                                [];
                                                            ci.add(snapshot
                                                                .data![index]
                                                                .name);
                                                            ci.addAll(_locationServices
                                                                .getCityOfProvince(
                                                                    snapshot
                                                                        .data![
                                                                            index]
                                                                        .id)
                                                                .map((e) =>
                                                                    snapshot
                                                                        .data![
                                                                            index]
                                                                        .name +
                                                                    "_" +
                                                                    e.name));
                                                            return GestureDetector(
                                                              onTap: () {
                                                                _currentLocation
                                                                    .add(ci[0]);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child:
                                                                  DropdownButton<
                                                                      String>(
                                                                value: ci[0],
                                                                icon: const Icon(
                                                                    Icons
                                                                        .arrow_drop_down_outlined),
                                                                iconSize: 24,
                                                                elevation: 16,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .deepPurple),
                                                                underline:
                                                                    Container(
                                                                  height: 2,
                                                                  color: Colors
                                                                      .deepPurpleAccent,
                                                                ),
                                                                onChanged:
                                                                    (newValue) {},
                                                                items: ci.map<
                                                                    DropdownMenuItem<
                                                                        String>>((String
                                                                    value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child:
                                                                        GestureDetector(
                                                                      child: Text(
                                                                          value),
                                                                      onTap:
                                                                          () {
                                                                        _currentLocation
                                                                            .add(value);
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            );
                                                          },
                                                          itemCount: snapshot
                                                              .data!.length),
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            Navigator.pop(c);
                                                          });
                                                        },
                                                        child: Text("اعمال"))
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          },
                                        ),
                                      );
                                    });
                              },
                              icon: const Icon(
                                CupertinoIcons.location,
                                color: Colors.deepPurple,
                                size: 16,
                              )),
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
                          const SizedBox(
                            width: 4,
                          ),
                          const Text(":موقعیت مکانی "),
                          const SizedBox(
                            width: 30,
                          )
                        ],
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 10,
                  ),
                  child: Form(
                    key: _captionFormKey,
                    child: TextFormField(
                      controller: _captionController,
                      decoration: buildInputDecoration("توضیحات"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "مقادیر درخواستی را وارد کنید";
                        }
                      },
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: GestureDetector(
                child: const Center(
                    child: Text(
                  "ثبت در خواست",
                  style: TextStyle(color: Colors.blue, fontSize: 17),
                )),
                onTap: () async {
                  if (_measureFormKey.currentState?.validate() ?? false) {
                    if (_valueFormKey.currentState?.validate() ?? false) {
                      if (_captionFormKey.currentState?.validate() ?? false) {
                        var account = await _accountDao.getAccount();
                        if (account != null) {
                          _sendMessage(account);
                        } else {
                          showDialog(
                              context: context,
                              builder: (c) {
                                return AlertDialog(
                                  title: const Center(
                                    child: Text(
                                      "ابتدا باید لاگین کنید.",
                                      style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontSize: 20),
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                          maxLength: 11,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          controller: _textController,
                                          decoration: const InputDecoration(
                                              suffixIcon: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 20, left: 25),
                                                child: Text(
                                                  "*",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              border: OutlineInputBorder(),
                                              hintText: "09121234567",
                                              labelStyle: TextStyle(
                                                  color: Colors.cyanAccent),
                                              labelText: "شماره تلفن")),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextButton(
                                            onPressed: () {
                                              if (_textController
                                                      .text.isNotEmpty &&
                                                  _textController.text.length ==
                                                      11) {
                                                _accountDao.saveAccount(Account(
                                                    int.parse(
                                                        _textController.text)));
                                                _sendMessage(Account(int.parse(
                                                    _textController.text)));
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text("ثبت نام")),
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                      }
                    }
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _sendMessage(Account account) {
    _messageRepo.sendMessage(
        Message(
          owner_id: account.phoneNumber.toString(),
          fileUuid: account.phoneNumber.toString() +
              DateTime.now().millisecondsSinceEpoch.toString(),
          caption: _captionController.text,
          isPined: false,
          ownerPhoneNumber: account.phoneNumber,
          time: DateTime.now().millisecondsSinceEpoch,
          messageType: _valueSubject.value,
          measure: int.parse(_measureController.text),
          value: int.parse(_valueController.text),
          location: _currentLocation.value,
        ),
        _selectedFilePath);
    FToast fToast = FToast();
    fToast.init(context);

    fToast.showToast(
      child: const Text(
        ".آگهی شما ثبت شد",
        style: TextStyle(fontSize: 23),
      ),
      gravity: ToastGravity.CENTER,
      toastDuration: const Duration(seconds: 1),
    );
    Timer(Duration(milliseconds: 400), () {
      Navigator.pop(context);
    });
  }

  Widget picturePage() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50),
      child: GridView.builder(
        itemCount: _selectedFilePath.length + 1,
        itemBuilder: (c, index) {
          if (index == 0) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                  child: IconButton(
                      onPressed: () async {
                        var res = await FilePicker.platform.pickFiles(
                            type: FileType.image, allowMultiple: true);
                        if (res != null) {
                          for (var element in res.files) {
                            _selectedFilePath.add(element.path!);
                          }
                          setState(() {});
                        }
                      },
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 35,
                      ))),
            );
          } else {
            return Padding(
              padding:
                  const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 3),
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (c) {
                          return AlertDialog(
                            content: Image.file(
                              File(
                                _selectedFilePath[index - 1],
                              ),
                            ),
                          );
                        });
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: Image.file(
                          File(
                            _selectedFilePath[index - 1],
                          ),
                        ),
                      ),
                      Positioned(
                          child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).hoverColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        width: 30,
                        height: 30,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 10,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              _selectedFilePath.removeAt(index - 1);
                              setState(() {});
                            },
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            );
          }
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 550 ? 5 : 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: (1 / 1),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(label) {
    return InputDecoration(
        suffixIcon: const Padding(
          padding: EdgeInsets.only(top: 20, left: 25),
          child: Text(
            "*",
            style: TextStyle(color: Colors.red),
          ),
        ),
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.deepPurple),
        labelText: label);
  }
}
