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

setRestApiPort(int port) {
  storage.write(key: 'restApiPort', value: "$port");
}

// encryption and decryption key
Future<String> getKey() async {
  return await storage.read(key: 'key') ?? '';
}

setKey(String key) async {
  storage.write(key: 'key', value: key);
}

Future<bool> getLazyAuthMode() async {
  var lazyAuthModeString = await storage.read(key: 'lazyAuthMode');
  bool lazyAuthMode = bool.tryParse(lazyAuthModeString ?? 'false') ?? false;
  return lazyAuthMode;
}

setLazyAuthMode(bool lazyAuthMode) async {
  storage.write(key: 'lazyAuthMode', value: lazyAuthMode.toString());
}
