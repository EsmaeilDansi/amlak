import 'package:Amlak/db/entity/chat.dart';
import 'package:hive/hive.dart';

class ChatDao {
  Future<Box<Chat>> _open() async {
    return await Hive.openBox<Chat>("chat");
  }

  save(Chat chat) async {
    var box = await _open();
    box.put(chat.id, chat);
  }

  Stream<List<Chat>?>? getChat(String messageId, String from) async* {
    var box = await _open();
    box.values.forEach((element) {
      // print(element.from + from);
      // print(element.to+to);
    });

    yield sorted(box.values
        .where((element) =>
            element.messageId.contains(messageId) &&
            (element.from.toString().contains(from) ||
                element.to.toString().contains(from)))
        .toList());

    yield* box.watch().map((event) => sorted(box.values
        .where((element) =>
            element.messageId.contains(messageId) &&
            (element.from.toString().contains(from) ||
                element.to.toString().contains(from)))
        .toList()));
  }

  List<Chat> sorted(List<Chat> list) {
    list.sort((a, b) => (b.time) - (a.time));

    return list;
  }
}
