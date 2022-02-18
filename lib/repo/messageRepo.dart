import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amlak_client/db/dao/fileDao.dart';
import 'package:amlak_client/db/dao/messageDao.dart';
import 'package:amlak_client/db/entity/file.dart' as f;
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/services/permissionServices.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:http_parser/http_parser.dart';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

String BASE_URI = "http://192.168.25.61:8090";

class MessageRepo {
  final _messageDao = GetIt.I.get<MessageDao>();
  final _fileDao = GetIt.I.get<FileDao>();

  initBaseUri()async{
    final ipv4 = await Ipify.ipv4();
    print(ipv4);
  }

  Future<String> get _localPath async {
    if (Platform.isWindows ||
        await GetIt.I.get<PermissionServices>().getStoragePermission()) {
      final directory = await getApplicationDocumentsDirectory();
      if (!await Directory('${directory.path}/Amlak').exists()) {
        await Directory('${directory.path}/Amlak').create(recursive: true);
      }
      return directory.path + "/Amlak";
    }
    throw Exception("There is no Storage Permission!");
  }

  Future<void> sendMessage(Message message, List<String> filesPath) async {
    if (filesPath.isEmpty) {
      _sendMessage(message);
    } else {
      try {
        await _sendFile(filesPath, message.fileUuid!);
        _sendMessage(message);
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
  }

  Future<void> _sendMessage(Message message) async {
    var rng = Random();
    try {
      String id = DateTime.now().millisecondsSinceEpoch.toString() +
          rng.nextInt(1000000).toString();
      var res = await post(
        Uri.parse(
          '$BASE_URI/setPost/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'id': id,
          'value': message.value.toString(),
          'file_uuid': message.fileUuid!,
          'owner_id': message.owner_id,
          'caption': message.caption,
          'location': message.location,
          'create_time': message.time.toString(),
          'phone_number': message.ownerPhoneNumber.toString(),
          'measure': message.measure.toString(),
          'type': message.messageType.toString()
        }),
      );
      _messageDao.saveMessage(message..id = res.body);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> deleteMessage(Message message) async {
    try {
      var res = await get(Uri.parse("$BASE_URI/deleteMessage/${message.id}"));
      if (res.statusCode == 200) {
        _messageDao.deleteMessage(message);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  _fetchDeletedMessage(String time) async {
    var res = await get(Uri.parse("$BASE_URI/getDeletedMessage/0"));
    List<dynamic> messages = jsonDecode(res.body);
    for (var element in messages) {
      var m = await _messageDao.getMessage(element.toString());
      if (m != null) {
        _messageDao.deleteMessage(m);
      }
    }
  }

  Future<void> fetchMessage() async {
    _fetchMessage();
  }

  Future<void> _fetchMessage() async {
    Message? lastMsg = await _messageDao.getLastMessage();
    String time = lastMsg != null ? lastMsg.time.toString() : "0";
    var res = await get(
      Uri.parse('$BASE_URI/getAllMessage/$time'),
    );
    List<dynamic> messages = jsonDecode(res.body);
    for (var element in messages) {
      _messageDao.saveMessage(
        Message(
            owner_id: element["owner_id"] ?? "",
            messageType: getMsgType(element["type"]),
            fileUuid: element["file_uuid"],
            value: element["value"],
            ownerPhoneNumber: element["phone_number"],
            caption: utf8.decode(element["caption"].toString().codeUnits),
            id: element["id"].toString(),
            isPined: false,
            location: utf8.decode(element["location"].toString().codeUnits),
            time: element["create_time"],
            measure: element["measure"]),
      );
    }
    _fetchDeletedMessage(time);
  }

  MessageType getMsgType(String type) {
    if (type.contains("forosh")) {
      return MessageType.forosh;
    } else if (type.contains("kharid")) {
      return MessageType.kharid;
    } else if (type.contains("ajara_dadan")) {
      return MessageType.ajara_dadan;
    } else if (type.contains("ajara_kardan")) {
      return MessageType.ajara_kardan;
    } else if (type.contains("rahn_dadan")) {
      return MessageType.rahn_dadan;
    } else {
      return MessageType.rahn_kardan;
    }
  }

  Future<String?> downloadFile(String uuid) async {
    try {
      var res = await get(Uri.parse("$BASE_URI/getFile/$uuid"));
      var path = (await _localPath) + "/$uuid";
      final file = File(path);
      file.writeAsBytesSync(res.bodyBytes);
      return path;
    } catch (e) {
      return null;
    }
  }

  Future<List<f.File>?> getMessageFile(String messageId) async {
    var res = await _fileDao.getFileOfMessage(messageId);
    if (res != null && res.isNotEmpty) {
      return res;
    } else {
      return _getFileInfo(messageId);
    }
  }

  Future<List<f.File>?> _getFileInfo(String messageId) async {
    List<f.File> result = [];
    try {
      var res = await get(Uri.parse("$BASE_URI/fileInfo/$messageId"));
      List<dynamic> fileInfos = jsonDecode(res.body) as List;
      fileInfos.forEach((element) async {
        var path = await downloadFile(element["file_uuid"]);
        if (path != null) {
          var file = f.File(
              path,
              utf8.decode(element["file_uuid"].toString().codeUnits),
              messageId);
          _fileDao.saveFile(file);
          result.add(file);
        }
      });
    } catch (e) {
      return null;
    }
  }

  _sendFile(List<String> filesPath, String messageFileId) async {
    filesPath.forEach((element) async {
      d.FormData formData = d.FormData.fromMap({
        "file": d.MultipartFile.fromFileSync(
          element,
          contentType: MediaType.parse("application/octet-stream"),
        )
      });

      d.Dio dio = d.Dio();
      await dio.post("$BASE_URI/upload/$messageFileId",
          data: formData,
          options: d.Options(
            followRedirects: false,
            // will not throw errors
            validateStatus: (status) => true,
          ));
      _fileDao
          .saveFile(f.File(element, messageFileId + element, messageFileId));
    });
  }
}
