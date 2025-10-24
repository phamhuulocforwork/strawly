import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtils {
  EncryptionUtils._();

  /// Generate a random encryption key (32 bytes for AES-256)
  static Uint8List generateSecureKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
  }

  /// Convert key bytes to base64 string for storage
  static String keyToString(Uint8List key) {
    return encrypt.Key(key).base64;
  }

  /// Convert base64 string to key bytes
  static Uint8List stringToKey(String keyString) {
    return encrypt.Key.fromBase64(keyString).bytes;
  }

  /// Encrypt a string value
  static String encryptString(String value, Uint8List key) {
    final keyObj = encrypt.Key(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyObj));

    final encrypted = encrypter.encrypt(value, iv: iv);
    return encrypted.base64;
  }

  /// Decrypt a string value
  static String decryptString(String encryptedValue, Uint8List key) {
    final keyObj = encrypt.Key(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyObj));

    final decrypted = encrypter.decrypt64(encryptedValue, iv: iv);
    return decrypted;
  }
}
