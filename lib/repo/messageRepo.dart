import 'dart:convert';
import 'dart:io';

import 'package:amlak_client/db/dao/fileDao.dart';
import 'package:amlak_client/db/dao/messageDao.dart';
import 'package:amlak_client/db/entity/file.dart' as f;
import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:amlak_client/services/permissionServices.dart';
import 'package:dio/dio.dart' as d;

import 'package:http_parser/http_parser.dart';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

String BASE_URI = "http://127.0.0.1:8090";

class MessageRepo {
  final _messageDao = GetIt.I.get<MessageDao>();
  final _fileDao = GetIt.I.get<FileDao>();

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

  Future<void> sendMessage(Message message) async {
    var res = await post(
      Uri.parse(
        '$BASE_URI/setPost/',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'id': '0',
        'value': message.value.toString(),
        'file_uuid': message.fileUuid!,
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

  Future<String?> downloadFile(String uuid) async {
    try {
      var res = await get(Uri.parse("$BASE_URI/$uuid"));
      var path = (await _localPath) + "/$uuid";
      final file = await File(path);
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
      return getFileInfo(messageId);
    }
  }

  Future<List<f.File>?> getFileInfo(String messageId) async {
    List<f.File> result = [];
    try {
      var res = await get(Uri.parse("$BASE_URI/fileInfo/$messageId"));
      List<dynamic> fileInfos = jsonDecode(res.body) as List;
      fileInfos.forEach((element) async {
        var path = await downloadFile(element["file_uuid"]);
        if (path != null) {
          var file = f.File(path, element["file_uuid"], messageId);
          _fileDao.saveFile(file);
          result.add(file);
        }
      });
    } catch (e) {
      return null;
    }
  }

  sendReqMessage() {}

  sendSaleMessage() {}

  sendFile(String filePath, String messageFileId) async {
    d.FormData formData = d.FormData.fromMap({
      "file": d.MultipartFile.fromFileSync(
        filePath,
        contentType: MediaType.parse("application/octet-stream"),
      )
    });

    d.Dio dio = d.Dio();
    await dio.post("$BASE_URI/upload/$messageFileId", data: formData);
  }
}
