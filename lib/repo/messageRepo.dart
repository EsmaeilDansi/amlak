import 'dart:convert';

import 'package:amlak_client/db/dao/messageDao.dart';
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:dio/dio.dart' as d;

import 'package:http_parser/http_parser.dart';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

String BASE_URI = "http://127.0.0.1:8090";

class MessageRepo {
  final _messageDao = GetIt.I.get<MessageDao>();

  Future<void> sendMessage(Message message) async {
    var res = await post(
      Uri.parse(
        '$BASE_URI/setPost/',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'id': '0',
        'value': message.value.toString(),
        'file_uuid': '4d3',
        'owner_id': message.owner_id,
        'caption': message.caption,
        'location': message.location,
        'time': message.time.toString(),
        'type': message.messageType.toString()
      }),
    );
    _messageDao.saveMessage(message..id = res.body);
  }

  Future<List<Message>?> fetchMessage() async {
    var res = await get(Uri.parse("$BASE_URI/getAllMessage/"));
    List<dynamic> messages = jsonDecode(res.body);
    for (var element in messages) {
      _messageDao.saveMessage(
        Message(
            owner_id: element["owner_id"] ?? "",
            messageType: getMsgType(element["type"]),
            packId: element["packId"] ?? "",
            value: element["value"],
            caption: element["caption"],
            location: element["location"],
            time: element["create_time"]),
      );
    }
  }

  MessageType getMsgType(String type) {
    if (type.contains("req")) {
      return MessageType.Req;
    } else {
      return MessageType.Sale;
    }
  }

  sendFile(String filePath) async {
    d.FormData formData = d.FormData.fromMap({
      "file": d.MultipartFile.fromFileSync(
        filePath,
        contentType: MediaType.parse("application/octet-stream"),
      )
    });

    d.Dio dio = d.Dio();
    var res = await dio.post("$BASE_URI/upload/", data: formData);
  }
}
