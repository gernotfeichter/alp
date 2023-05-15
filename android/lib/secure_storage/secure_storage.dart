import 'package:flutter_secure_storage/flutter_secure_storage.dart';

var storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
  encryptedSharedPreferences: true,
));

int restApiPort = (storage.read(key: 'restApiPort') as int) == 0 ?
  7654 :
  (storage.read(key: 'restApiPort') as int);
