import 'dart:core';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

var storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
  encryptedSharedPreferences: true,
));

Future<int> restApiPort() async {
  var strValue = await storage.read(key: 'restApiPort');
  if (strValue == null || strValue == "") {
    return 7654;
  }
  return int.parse(strValue);
}
