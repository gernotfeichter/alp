// Source: https://github.com/java-crypto/cross_platform_crypto/tree/main/AesGcm256Pbkdf2StringEncryption

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import "package:pointycastle/export.dart";

String aesGcmPbkdf2EncryptToBase64(String password, String plaintext) {
  var plaintextUint8 = createUint8ListFromString(plaintext);
  var passphrase =  createUint8ListFromString(password);
  const pbkdf2Iterations = 15000;
  final salt = generateSalt32Byte();
  KeyDerivator derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  Pbkdf2Parameters params = Pbkdf2Parameters(salt, pbkdf2Iterations, 32);
  derivator.init(params);
  final key = derivator.process(passphrase);
  final nonce = generateRandomNonce();
  final cipher = GCMBlockCipher(AESEngine());
  var aeadParameters = AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0));
  cipher.init(true, aeadParameters);
  var ciphertextWithTag = cipher.process(plaintextUint8);
  var ciphertextWithTagLength = ciphertextWithTag.lengthInBytes;
  var ciphertextLength = ciphertextWithTagLength - 16; // 16 bytes = 128 bit tag length
  var ciphertext = Uint8List.sublistView(ciphertextWithTag, 0, ciphertextLength);
  var gcmTag = Uint8List.sublistView(ciphertextWithTag, ciphertextLength, ciphertextWithTagLength);
  final saltBase64 = base64Encoding(salt);
  final nonceBase64 = base64Encoding(nonce);
  final ciphertextBase64 = base64Encoding(ciphertext);
  final gcmTagBase64 = base64Encoding(gcmTag);
  return '$saltBase64:$nonceBase64:$ciphertextBase64:$gcmTagBase64';
}

String aesGcmPbkdf2DecryptFromBase64(String password, String data) {
  var parts = data.split(':');
  var salt = base64Decoding(parts[0]);
  var nonce = base64Decoding(parts[1]);
  var ciphertext = base64Decoding(parts[2]);
  var gcmTag = base64Decoding(parts[3]);
  var bb = BytesBuilder();
  bb.add(ciphertext);
  bb.add(gcmTag);
  var ciphertextWithTag = bb.toBytes();
  var passphrase =  createUint8ListFromString(password);
  const pbkdf2Iterations = 15000;
  KeyDerivator derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  Pbkdf2Parameters params = Pbkdf2Parameters(salt, pbkdf2Iterations, 32);
  derivator.init(params);
  final key = derivator.process(passphrase);
  final cipher = GCMBlockCipher(AESEngine());
  var aeadParameters = AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0));
  cipher.init(false, aeadParameters);
  return String.fromCharCodes(cipher.process(ciphertextWithTag));
}

Uint8List generateSalt32Byte() {
  final sGen = Random.secure();
  final seed =
  Uint8List.fromList(List.generate(32, (n) => sGen.nextInt(255)));
  SecureRandom sec = SecureRandom("Fortuna")..seed(KeyParameter(seed));
  return sec.nextBytes(32);
}

Uint8List generateRandomNonce() {
  final sGen = Random.secure();
  final seed =
  Uint8List.fromList(List.generate(32, (n) => sGen.nextInt(255)));
  SecureRandom sec = SecureRandom("Fortuna")..seed(KeyParameter(seed));
  return sec.nextBytes(12);
}

Uint8List createUint8ListFromString(String s) {
  var ret = Uint8List(s.length);
  for (var i = 0; i < s.length; i++) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}

String base64Encoding(Uint8List input) {
  return base64.encode(input);
}

Uint8List base64Decoding(String input) {
  return base64.decode(input);
}

