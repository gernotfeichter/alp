import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
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
    log.fine("Running in ${Isolate.current.debugName}");

    // request
    String host;
    DateTime requestExpirationTime;
    String encryptionDecryptionKey = await getKey();
    try {
      String decryptedMessage = "";
      Map bodyAsJsonMap = await req.body as Map;
      try {
        if (encryptionDecryptionKey == '') {
          log.severe("Decryption Key is empty, please configure a key!");
        } else {
          decryptedMessage = aesGcmPbkdf2DecryptFromBase64(encryptionDecryptionKey, bodyAsJsonMap['encryptedMessage']);
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
    var notificationTimeoutSeconds = requestExpirationTime.difference(DateTime.now()).inSeconds;
    if (notificationTimeoutSeconds < 0) {
      res.statusCode = HttpStatus.badRequest;
      var errMsg = "Calculated notificationTimeoutSeconds is negative. This could have multiple reasons like your phone vs linux machine times being out of sync, very low configured timeout or very poor device or network performance.";
      log.severe(errMsg);
      return '{"error": "$errMsg"}';
    }
    log.fine("notificationTimeoutSeconds=$notificationTimeoutSeconds");
    var notificationId = createNotificationAuthRequest(
        timeoutSeconds: notificationTimeoutSeconds,
        title: "Alp auth request from $host");
    log.info("created notification for auth request from host: $host");
    var approved = await pollForNotificationResult(
        notificationId, notificationTimeoutSeconds);

    // response
    var encryptedMessage = aesGcmPbkdf2EncryptToBase64(
        encryptionDecryptionKey,
        '{"auth":$approved}');
    var approvedMessage = "auth request from host $host ${approved ? "approved" : "denied"}";
    if (approved) {
      log.info(approvedMessage);
    } else {
      log.severe(approvedMessage);
    }
    return '{"encryptedMessage":"$encryptedMessage"}';
  });

  var port = await getRestApiPort();
  await app.listen(port);
  log.info("Listening on port $port");
}

Future<bool> pollForNotificationResult(int notificationId, int timeoutSeconds) async {
  int timeOutMilliseconds = timeoutSeconds * 1000;
  int millisecondsConsumed = 0;
  int sleepIntervalMilliseconds = 250;
  while (millisecondsConsumed < timeOutMilliseconds) {
    if (authRequestNotificationStateHistory.any(
            (map) => map[notificationId] == true)
    ) {
      return true;
    }
    if (authRequestNotificationStateHistory.any(
            (map) => map[notificationId] == false)
    ) {
      log.fine("stopped polling for auth success because authRequestNotificationStateHistory for (id=$notificationId) contains already a negative result: $authRequestNotificationStateHistory");
      return false;
    }
    await Future.delayed(Duration(milliseconds: sleepIntervalMilliseconds));
    millisecondsConsumed += sleepIntervalMilliseconds;
  }
  log.fine("stopped polling for auth success because of timeout");
  return false;
}
