
import 'package:Amlak/db/entity/room.dart';
import 'package:hive/hive.dart';

class RoomDao {
  Future<Box<Room>> _open() async {
    return await Hive.openBox<Room>("room");
  }

  save(Room room, String key) async {
    var box = await _open();
    box.put(key, room);
  }

  Future<List<Room>?> getAllRooms() async {
    var box = await _open();
    return sorted(box.values.toList());
  }

  List<Room> sorted(List<Room> list) {
    list.sort((a, b) => (b.time) - (a.time));

    return list;
  }
}
