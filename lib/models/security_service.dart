import 'package:flutter/foundation.dart';

class SecurityService {
  SecurityService._();

  static bool _biometricEnabled = false;
  static final ValueNotifier<bool> biometricNotifier = ValueNotifier(false);

  static bool get biometricEnabled => _biometricEnabled;

  static void setBiometric(bool v) {
    _biometricEnabled = v;
    biometricNotifier.value = v;
  }
}
