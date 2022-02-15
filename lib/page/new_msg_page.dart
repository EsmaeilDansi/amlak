import 'dart:io';

import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/repo/messageRepo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class NewMessagePage extends StatefulWidget {
  final Function back;

  const NewMessagePage({Key? key, required this.back}) : super(key: key);

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  final BehaviorSubject<MessageType> _valueSubject =
      BehaviorSubject.seeded(MessageType.Sale);
  final List<String> _selectedFilePath = [];
  final _positionFormKey = GlobalKey<FormState>();
  final _captionFormKey = GlobalKey<FormState>();
  final _valueFormKey = GlobalKey<FormState>();
  final _measureFormKey = GlobalKey<FormState>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _locationController = TextEditingController();
  final _valueController = TextEditingController();
  final _measureController = TextEditingController();
  final _captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ثبت  آگهی "),
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
                                  "آگهی فروش",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: MessageType.Sale,
                              ),
                              DropdownMenuItem(
                                child: Text(
                                  "آگهی درخواست",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: MessageType.Req,
                              )
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
                        if (snapshot.data == MessageType.Sale) {
                          int w = MediaQuery.of(context).size.width.toInt();
                          return SizedBox(
                              height: w > 500 && _selectedFilePath.length > 4 ||
                                      w < 500 && _selectedFilePath.length > 2
                                  ? 200
                                  : 140,
                              child: picturePage());
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    top: 8,
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
                  child: Form(
                    key: _positionFormKey,
                    child: TextFormField(
                      controller: _locationController,
                      decoration: buildInputDecoration("موقعیت جغرافیایی"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "مقادیر درخواستی را وارد کنید";
                        }
                      },
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
          Container(
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
              onTap: () {
                if (_measureFormKey.currentState?.validate() ?? false) {
                  if (_valueFormKey.currentState?.validate() ?? false) {
                    if (_positionFormKey.currentState?.validate() ?? false) {
                      if (_captionFormKey.currentState?.validate() ?? false) {
                        _messageRepo.sendMessage(
                            Message(
                              owner_id: "123456",
                              fileUuid: "123456" +
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              caption: _captionController.text,
                              isPined: false,
                              time: DateTime.now().millisecondsSinceEpoch,
                              messageType: _valueSubject.value,
                              measure: int.parse(_measureController.text),
                              value: int.parse(_valueController.text),
                              location: _locationController.text,
                            ),
                            _selectedFilePath);
                      }
                      FToast fToast = FToast();
                      fToast.init(context);

                      fToast.showToast(
                        child: Text("آگهی شما ثبت شد."),
                        gravity: ToastGravity.BOTTOM,
                        toastDuration: const Duration(seconds: 2),
                      );
                      widget.back();
                    }
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget picturePage() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50),
      child: GridView.builder(
        itemCount: _selectedFilePath.length + 1,
        itemBuilder: (c, index) {
          if (index == 0) {
            return Container(
              width: 170,
              height: 170,
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
            crossAxisCount: MediaQuery.of(context).size.width > 550 ? 5 : 3),
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
        labelStyle: TextStyle(color: Colors.cyanAccent),
        labelText: label);
  }
}
