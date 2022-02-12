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
  const NewMessagePage({Key? key}) : super(key: key);

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
                                child: Text("آگهی فروش"),
                                value: MessageType.Sale,
                              ),
                              DropdownMenuItem(
                                child: Text("آگهی درخواست"),
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
                child: Text("نوع آگهی"),
              ),
            ],
          ),
          const Divider(),
          StreamBuilder<MessageType>(
              stream: _valueSubject.stream,
              builder: (c, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data == MessageType.Sale) {
                    return SizedBox(
                      height: 200,
                        child: Scrollbar(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text("انتخاب عکس برای آگهی"),
                              picturePage(),
                            ],
                          ),
                        ));
                  } else {
                    return const SizedBox.shrink();
                  }
                } else {
                  return const SizedBox.shrink();
                }
              }),
          inputInformationPage(),
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
                              time: DateTime.now().millisecondsSinceEpoch,
                              messageType: _valueSubject.value,
                              measure: int.parse(_measureController.text),
                              value: int.parse(_valueController.text),
                              location: _locationController.text,
                            ),
                            _selectedFilePath);
                      }
                      //   Fluttertoast.showToast(msg: "آگهی شما ثبت شد.");
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
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 50, right: 50),
              child: GridView.builder(
                itemCount: _selectedFilePath.length + 1,
                itemBuilder: (c, index) {
                  if (index == 0) {
                    return Container(
                      width: 300,
                      height: 200,
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
                      padding: const EdgeInsets.only(
                          left: 3, right: 3, top: 3, bottom: 3),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.file(
                                File(_selectedFilePath[index - 1],),width: 200,height: 200,
                              ),
                            ),
                            Positioned(
                                child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .hoverColor
                                    .withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _selectedFilePath.removeAt(index - 1);
                                  setState(() {});
                                },
                              ),
                            ))
                          ],
                        ),
                      ),
                    );
                  }
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget inputInformationPage() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Form(
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
            SizedBox(
              height: 20,
            ),
            Form(
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
            SizedBox(
              height: 20,
            ),
            Form(
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
            SizedBox(
              height: 20,
            ),
            Form(
              key: _captionFormKey,
              child: TextFormField(
                controller: _captionController,
                decoration: buildInputDecoration("توضیحات"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "مقادیر درخواستی را وارد کنید";
                  }
                },
              ),
            ),
          ],
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
        labelText: label);
  }
}
