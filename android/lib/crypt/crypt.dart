import 'dart:io';
import 'dart:convert';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/gcm.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/block/modes/cfb.dart';
import 'package:pointycastle/block/modes/ctr.dart';
import 'package:pointycastle/block/modes/ecb.dart';
import 'package:pointycastle/block/modes/ofb.dart';
import 'package:pointycastle/block/modes/sic.dart';
import 'package:pointycastle/random/fortuna_random.dart';

void main() {
  final plaintext = 'Hello, World!';
  final key = '01234567890123456789012345678901';

  final encryptedText = Encrypt(plaintext, key);
  print('Encrypted Text: $encryptedText');

  final decryptedText = Decrypt(encryptedText, key);
  print('Decrypted Text: $decryptedText');
}

String Encrypt(String plaintext, String key) {
  validateKey(key);
  final gcm = initCipher(key);
  final nonce = generateNonce(gcm.nonceSize);
  final cipherText = gcm.process(
    nonce,
    0,
    nonce.length,
    utf8.encode(plaintext),
  );
  return base64.encode(cipherText);
}

String Decrypt(String ciphertext, String key) {
  validateKey(key);
  final gcm = initCipher(key);
  final nonceSize = gcm.nonceSize;
  final cipherText = base64.decode(ciphertext);
  final nonce = cipherText.sublist(0, nonceSize);
  final encryptedData = cipherText.sublist(nonceSize);
  final decryptedData = gcm.process(nonce, 0, nonce.length, encryptedData);
  return utf8.decode(decryptedData);
}

GCMBlockCipher initCipher(String key) {
  final cipher = AESFastEngine();
  final gcm = GCMBlockCipher(cipher);
  final params = AEADParameters(KeyParameter(utf8.encode(key)), 128, Uint8List(12));
  gcm.init(true, params); // true for encryption, false for decryption
  return gcm;
}

Uint8List generateNonce(int size) {
  final random = FortunaRandom();
  final nonce = Uint8List(size);
  random.nextBytes(nonce);
  return nonce;
}

void validateKey(String key) {
  final keySize = key.length;
  if (keySize != 32) {
    throw Exception('Expected a key size of 32, got: $keySize');
  }
}
