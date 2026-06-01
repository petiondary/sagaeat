import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrService {
  QrService._();

  // Kontni QR code — backend pral valide via orderId + delivery token apre
  static String qrContent(String orderId) => 'sagaeat://deliver/$orderId';

  static String _safeId(String orderId) =>
      orderId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  // Sove QR kòm PNG sou dosye entèn app la
  static Future<String?> saveQrImage(String orderId) async {
    try {
      final painter = QrPainter(
        data: qrContent(orderId),
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );
      final byteData = await painter.toImageData(512);
      if (byteData == null) return null;
      final bytes = byteData.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final qrDir = Directory('${dir.path}/qr_codes');
      if (!qrDir.existsSync()) await qrDir.create(recursive: true);

      final file = File('${qrDir.path}/qr_${_safeId(orderId)}.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // Verifye si QR deja sove
  static Future<bool> hasSavedQr(String orderId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File(
        '${dir.path}/qr_codes/qr_${_safeId(orderId)}.png',
      ).existsSync();
    } catch (_) {
      return false;
    }
  }
}
