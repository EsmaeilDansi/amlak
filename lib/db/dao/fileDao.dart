import 'package:amlak_client/db/entity/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

class FileDao {
  Future<Box<File>> _open() async {
    return await Hive.openBox<File>("file");
  }

  saveFile(File file) async {
    print(file.uuid.toString());
    var box = await _open();
    box.put(file.uuid, file);
  }

  Future<File?> getFile(String uuid) async {
    var box = await _open();
    return box.values.firstWhere((element) => element.uuid == uuid);
  }

  Future<List<File>?> getFileOfMessage(String messageId) async {
    var box = await _open();
    return box.values
        .where((element) => element.messageId == messageId)
        .toList();
  }
  

}
