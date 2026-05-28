import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  static Future<void> requestAll() async {
    await [
      Permission.location,
      Permission.camera,
      Permission.photos,
      Permission.notification,
    ].request();
  }

  static Future<bool> get hasLocation async =>
      await Permission.location.isGranted;

  static Future<bool> get hasCamera async =>
      await Permission.camera.isGranted;

  static Future<bool> get hasNotification async =>
      await Permission.notification.isGranted;

  static Future<void> requestLocation() async =>
      await Permission.location.request();

  static Future<void> requestCamera() async =>
      await Permission.camera.request();

  static Future<void> requestNotification() async =>
      await Permission.notification.request();
}
