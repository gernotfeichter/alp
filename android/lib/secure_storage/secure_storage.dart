import 'dart:core';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

var storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
  encryptedSharedPreferences: true,
));

Future<int> getRestApiPort() async {
  var strValue = await storage.read(key: 'restApiPort');
  if (strValue == null || strValue == "") {
    return 7654;
  }
  return int.parse(strValue);
}

Future<void> setRestApiPort(int port) async {
  await storage.write(key: 'restApiPort', value: "$port");
}

// encryption and decryption key
Future<String> getKey() async {
  return await storage.read(key: 'key') ?? '';
}

Future<void> setKey(String key) async {
  await storage.write(key: 'key', value: key);
}

Future<bool> getLazyAuthMode() async {
  var lazyAuthModeString = await storage.read(key: 'lazyAuthMode');
  bool lazyAuthMode = bool.tryParse(lazyAuthModeString ?? 'false') ?? false;
  return lazyAuthMode;
}

Future<void> setLazyAuthMode(bool lazyAuthMode) async {
  await storage.write(key: 'lazyAuthMode', value: lazyAuthMode.toString());
}

Future<int> getPbkdf2Iterations() async {
  var strValue = await storage.read(key: 'pbkdf2Iterations');
  if (strValue == null || strValue == "") {
    return 15000;
  }
  return int.parse(strValue);
}

Future<void> setPbkdf2Iterations(int iterations) async {
  await storage.write(key: 'pbkdf2Iterations', value: "$iterations");
}
