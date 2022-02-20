import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:Amlak/db/dao/accountDao.dart';
import 'package:Amlak/db/dao/chatDao.dart';
import 'package:Amlak/db/dao/fileDao.dart';
import 'package:Amlak/db/dao/messageDao.dart';
import 'package:Amlak/db/dao/roomDao.dart';
import 'package:Amlak/db/entity/chat.dart';
import 'package:Amlak/db/entity/file.dart' as f;
import 'package:Amlak/db/entity/message.dart';
import 'package:Amlak/db/entity/message_type.dart';
import 'package:Amlak/db/entity/room.dart';
import 'package:Amlak/services/permissionServices.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http_parser/http_parser.dart';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:win_toast/win_toast.dart';

const String baseUri = "http://192.168.25.61:8090";
const socketUri = '$baseUri/websocket-chat';

class MessageRepo {
  final _messageDao = GetIt.I.get<MessageDao>();
  final _fileDao = GetIt.I.get<FileDao>();
  final _accountDao = GetIt.I.get<AccountDao>();
  final _chatDao = GetIt.I.get<ChatDao>();
  final _roomDao = GetIt.I.get<RoomDao>();

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
          '$baseUri/setpost',
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
      print(res.body);
      _messageDao.saveMessage(message..id = res.body);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> deleteMessage(Message message) async {
    try {
      var res = await get(Uri.parse("$baseUri/deleteMessage/${message.id}"));
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
    var res = await get(Uri.parse("$baseUri/getDeletedMessage/0"));
    List<dynamic> messages = jsonDecode(res.body);
    for (var element in messages) {
      var m = await _messageDao.getMessage(element.toString());
      if (m != null) {
        _messageDao.deleteMessage(m);
      }
    }
  }

  StompClient? stompClient;

  createConnection() {
    try {
      stompClient = StompClient(
          config: StompConfig.SockJS(
              url: socketUri,
              onConnect: onConnect,
              onDisconnect: (s) {
                fetchChats();
              },
              onWebSocketError: (dynamic error) {
                fetchChats();
              },
              reconnectDelay: const Duration(milliseconds: 400)));

      stompClient!.activate();
    } catch (e) {
      print(e.toString());
    }
  }

  void onConnect(StompFrame frame) async {
    var account = await _accountDao.getAccount();
    if (account != null) {
      print(account.phoneNumber.toString());
      if (account != null) {
        stompClient!.subscribe(
            destination: '/topic/message/${account.phoneNumber}',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                _saveChat(frame.body!);
              }
            });
      }
    }
  }

  _saveChat(String body) {
    var res = jsonDecode(body);
    String from = res["sender"];
    String to = res["receiver"];
    String ownerId = res["ownerId"];
    String messageId = res["messageId"];
    _chatDao.save(Chat(
        id: res["id"].toString(),
        from: from,
        time: res["time"],
        messageId: messageId,
        content: res["content"],
        to: to));
    _roomDao.save(
        Room(
            time: res["time"],
            messageId: messageId,
            from: from,
            to: to,
            lastMessage: res["content"],
            ownerId: ownerId,
            isReed: false),
        messageId + ownerId + (from.contains(ownerId) ? to : from));

      showNotification(res["content"]);

  }

  sendChat(
      {required String content,
      required String from,
      required String to,
      required String ownerId,
      required String messageId}) async {
    try {
      var rng = Random();
      String id = DateTime.now().millisecondsSinceEpoch.toString() +
          rng.nextInt(1000000).toString();
      int time = DateTime.now().microsecondsSinceEpoch;
      await post(
        Uri.parse(
          "$baseUri/sendChat/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'id': id.toString(),
          'sender': from,
          'receiver': to,
          'time': time.toString(),
          'content': content,
          'messageId': messageId,
          'ownerId': ownerId
        }),
      );
      _chatDao.save(Chat(
          id: id.toString(),
          from: from,
          time: time,
          content: content,
          to: to,
          messageId: messageId));
      _roomDao.save(
          Room(
              isReed: true,
              messageId: messageId,
              from: from,
              to: to,
              lastMessage: content,
              time: time,
              ownerId: ownerId),
          messageId + ownerId + (from.contains(ownerId) ? to : from));
    } catch (e) {
      print(e.toString());
    }
  }

  fetchMessage() {
    _fetchMessage();
  }

  fetchChats() async {
    var res = await get(Uri.parse("$baseUri/getChat/0/0"));
    List<dynamic> chats = jsonDecode(res.body);
    for (var element in chats) {
      _saveChat(element);
    }
  }

  Future<void> _fetchMessage() async {
    try {
      Message? lastMsg = await _messageDao.getLastMessage();
      String time = lastMsg != null ? lastMsg.time.toString() : "0";
      var res = await get(
        Uri.parse('$baseUri/getAllMessage/$time'),
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
    } catch (e) {
      print(e.toString());
    }
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
      var res = await get(Uri.parse("$baseUri/getFile/$uuid"));
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
      var res = await get(Uri.parse("$baseUri/fileInfo/$messageId"));
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
      await dio.post("$baseUri/upload/$messageFileId",
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

showNotification(String content) async {
  if(Platform.isAndroid) {
    AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'Amlak',
            body: content));
  }else{
    await WinToast.instance().initialize(
        appName: 'Amlak',
        productName: 'wAmlak',
        companyName: 'Amlak');

    await WinToast.instance().showToast(
        type: ToastType.text01, title: content);
  }
}
