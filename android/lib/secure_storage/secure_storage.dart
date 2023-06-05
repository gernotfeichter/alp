import 'dart:core';

import '../logging/logging.dart';
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
Future<String?> getKey() async {
  return await storage.read(key: 'key');
}

setKey(String key) async {
  storage.write(key: 'key', value: key);
}