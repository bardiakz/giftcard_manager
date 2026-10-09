import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper over biometrics / device credential.
class Auth {
  Auth._();
  static final _auth = LocalAuthentication();

  static Future<bool> available() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Prompts for biometrics or the device PIN/pattern. If the device has no
  /// screen lock at all there is nothing to verify against, so it passes.
  static Future<bool> require(String reason) async {
    if (!await available()) return true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException {
      return false;
    }
  }
}
