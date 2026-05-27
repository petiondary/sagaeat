import 'package:flutter/foundation.dart';

class KycService {
  KycService._();

  static bool _isVerified = false;
  static final ValueNotifier<bool> verifiedNotifier = ValueNotifier(false);

  static bool get isVerified => _isVerified;

  static void markVerified() {
    _isVerified = true;
    verifiedNotifier.value = true;
  }
}
