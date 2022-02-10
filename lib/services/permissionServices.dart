import 'package:permission_handler/permission_handler.dart';

class PermissionServices {
  Future<void> getStoragePermission() async {
    if (!await Permission.photos.request().isGranted ||
        !await Permission.storage.isGranted ||
        !await Permission.accessMediaLocation.isGranted) {
      // You can request multiple permissions at once.
      await [
        Permission.photos,
        Permission.accessMediaLocation,
        Permission.storage,
      ].request();
    }
  }
}
