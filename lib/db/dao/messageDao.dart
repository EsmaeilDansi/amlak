import 'package:amlak_client/db/entity/message.dart';
import 'package:hive/hive.dart';

class MessageDao {
  Future<Box<Message>> _open() async {
    return await Hive.openBox<Message>("message");
  }

  saveMessage(Message message) async {
    var box = await _open();
    box.put(message.uuid, message);
  }

  Future<Message?> getMessage(String uuid) async {
    var box = await _open();
    return box.values.firstWhere((element) => element.uuid == uuid);
  }

  Stream<List<Message>> getAllMessage() async* {
    var box = await _open();

    yield sorted(box.values.toList());

    yield* box.watch().map((event) => sorted(box.values.toList()));
  }

  Stream<List<Message>> getAllMessageByValue(int min, int max) async* {
    var box = await _open();

    yield sorted(box.values
        .where((element) => min <= element.value && element.value <= max)
        .toList());

    yield* box.watch().map((event) => sorted(box.values
        .where((element) => min <= element.value && element.value <= max)
        .toList()));
  }

  Stream<List<Message>> getAllMessageByLocation(String location) async* {
    var box = await _open();

    yield sorted(
        box.values.where((element) => element.location == location).toList());

    yield* box.watch().map((event) => sorted(
        box.values.where((element) => element.location == location).toList()));
  }

  List<Message> sorted(List<Message> list) {
    list.sort((a, b) => (b.time) - (a.time));

    return list;
  }
}
