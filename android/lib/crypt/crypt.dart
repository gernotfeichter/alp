import 'package:encrypt/encrypt.dart';

class DecryptionError extends Error{}

String encryptAES(String plaintext, String key) {
  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.ctr));

  final iv = IV.fromLength(16); // Generate a random IV

  final encrypted = encrypter.encrypt(plaintext, iv: iv);
  return encrypted.base64;
}

String decryptAES(String ciphertext, String key) {
  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.ctr));

  final iv = IV.fromLength(16); // Generate a random IV

  final encrypted = Encrypted.fromBase64(ciphertext);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  return decrypted;
}
