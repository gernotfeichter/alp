import 'dart:convert';
import 'dart:io';
import 'package:alfred/alfred.dart';
import '../crypt/aes_gcm_256_pbkdf2_string_encryption.dart';
import '../logging/logging.dart';
import '../notifications/notifications.dart';
import '../secure_storage/secure_storage.dart';
import '../crypt/decryption_error.dart';

Future init() async {
  // Atm. of writing I could not find a lib for server dart codegen from
  // the openapi.yaml file, hence this is self-written.
  // The openapi.yaml is however used for the client code generation (linux side)!
  final app = Alfred(logLevel: LogType.debug);

  app.get('/auth', (req, res) async {
    // init
    res.headers.contentType = ContentType.json;

    // request
    String host;
    DateTime requestExpirationTime;
    try {
      String decryptedMessage = "";
      Map bodyAsJsonMap = await req.body as Map;
      try {
        var decryptionKey = await getKey();
        if (decryptionKey == null) {
          log.severe("Decryption Key is null, please configure a key!");
        } else {
          decryptedMessage = aesGcmPbkdf2DecryptFromBase64(decryptionKey, bodyAsJsonMap['encryptedMessage']);
        }
      } on Exception {
        throw DecryptionError();
      }
      var jsonPayload = jsonDecode(decryptedMessage);
      host = jsonPayload['host'];
      requestExpirationTime = DateTime.parse(jsonPayload['requestExpirationTime']);
    } on DecryptionError catch (e) {
      log.severe("DecryptionError: $e");
      res.statusCode = HttpStatus.unauthorized;
      return '{"error": "$e"}';
    } catch (e) {
      log.severe("Exception during parsing of request: $e");
      res.statusCode = HttpStatus.badRequest;
      return '{"error": "$e"}';
    }

    // notification
    var notificationTimeout = requestExpirationTime.difference(DateTime.now()).inSeconds;
    if (notificationTimeout < 0) {
      res.statusCode = HttpStatus.badRequest;
      return '{"error": "Calculated notificationTimeout is negative. This could have multiple reasons like your phone vs linux machine times being out of sync, very low configured timeout or very poor device or network performance."}';
    }
    log.fine("notificationTimeout=$notificationTimeout");
    createNotificationAuthRequest(timeoutSeconds: notificationTimeout, title: "Alp auth request from $host");

    // response
    res.headers.contentType = ContentType.json;
    return '{"encryptedMessage":"authenticated-true-json"}';
  });

  await app.listen(await getRestApiPort());
}
