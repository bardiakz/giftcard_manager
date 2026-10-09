import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Field-level AES-256-GCM encryption for card numbers and PINs.
/// The data key lives in the platform keystore (Android Keystore / iOS Keychain).
class FieldCipher {
  FieldCipher._(this._key);

  static final _algo = AesGcm.with256bits();
  final SecretKey _key;

  static Future<FieldCipher> load() async {
    const storage = FlutterSecureStorage();
    var b64 = await storage.read(key: 'dek_v1');
    if (b64 == null) {
      final key = await _algo.newSecretKey();
      b64 = base64Encode(await key.extractBytes());
      await storage.write(key: 'dek_v1', value: b64);
    }
    return FieldCipher._(SecretKey(base64Decode(b64)));
  }

  Future<String> encrypt(String plain) async {
    if (plain.isEmpty) return '';
    final box = await _algo.encrypt(utf8.encode(plain), secretKey: _key);
    return base64Encode(box.concatenation());
  }

  Future<String> decrypt(String encoded) async {
    if (encoded.isEmpty) return '';
    final box = SecretBox.fromConcatenation(
      base64Decode(encoded),
      nonceLength: _algo.nonceLength,
      macLength: _algo.macAlgorithm.macLength,
    );
    return utf8.decode(await _algo.decrypt(box, secretKey: _key));
  }
}
