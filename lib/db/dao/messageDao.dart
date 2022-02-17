import 'package:amlak_client/db/entity/message.dart';
import 'package:amlak_client/db/entity/message_type.dart';
import 'package:hive/hive.dart';

class MessageDao {
  Future<Box<Message>> _open() async {
    return await Hive.openBox<Message>("message");
  }

  saveMessage(Message message) async {
    var box = await _open();
    box.put(message.id.toString(), message);
  }

  Future<Message?> getMessage(String uuid) async {
    var box = await _open();
    return box.values.firstWhere((element) => element.id == uuid);
  }

  Stream<List<Message>> getAllMessage() async* {
    try {
      var box = await _open();

      yield sorted(box.values.toList()).reversed.toList();

      yield* box
          .watch()
          .map((event) => sorted(box.values.toList()).reversed.toList());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Message>> getAllMessageByValue(int min, int max) async {
    var box = await _open();

    return sorted(box.values
        .where((element) => min <= element.value && element.value <= max)
        .toList());
  }

  Stream<List<Message>> getAllMessageByLocationAndType(
      String location, String type) async* {
    var box = await _open();

    yield sorted(box.values
        .where((element) =>
            element.location.contains(location) &&
            element.messageType.name.contains(type))
        .toList());

    yield* box.watch().map((event) => sorted(box.values
        .where((element) =>
            element.location.contains(location) &&
            element.messageType.name.contains(type))
        .toList()));
  }

  List<Message> sorted(List<Message> list) {
    list.sort((a, b) => (b.time) - (a.time));

    return list;
  }

  Future<List<Message>> getAllMessageByDsc(String text) async {
    var box = await _open();
    return sorted(
        box.values.where((element) => element.caption.contains(text)).toList());
  }

  Future<List<Message>?> getPinnedMessage() async {
    var box = await _open();
    return sorted(box.values.where((element) => element.isPined).toList());
  }

  Future<Message?> getLastMessage() async {
    var box = await _open();
    return sorted(box.values.toList()).first;
  }

  void deleteMessage(Message message) async {
    var box = await _open();
    box.delete(message.id);
  }
}
