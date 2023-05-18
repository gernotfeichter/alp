import 'dart:convert';
import 'dart:io';
import 'package:aes256gcm/aes256gcm.dart';
import 'package:alfred/alfred.dart';
import '../crypt/crypt.dart';
import '../logging/logging.dart';
import '../notifications/notifications.dart';
import '../secure_storage/secure_storage.dart';

Future init() async {
  // Atm. of writing I could not find a lib for server dart codegen from
  // the openapi.yaml file, hence this is self-written.
  // The openapi.yaml is however used for the client code generation!
  final app = Alfred(logLevel: LogType.debug);

  app.get('/auth', (req, res) async {
    // init
    res.headers.contentType = ContentType.json;

    // request
    String host;
    DateTime requestExpirationTime;
    try {
      // String body = await req.body as String;
      // log.fine("request body: \n$body");
      var bodyAsJsonMap = await req.bodyAsJsonMap; // await json.decode(body);
      final String encryptedMessageEncoded = bodyAsJsonMap['encryptedMessage'];
      var encryptedMessageDecoded = base64.decode(encryptedMessageEncoded);
      String encryptedMessage = encryptedMessageDecoded.toString();
      String decryptedMessage;
      try {
        decryptedMessage = await Aes256Gcm.decrypt(encryptedMessage, 'GYTpQ8GRE23YOgB1DK0FBwUATnKPJliW'); // TODO: Gernot
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
    } on Exception catch (e) {
      log.severe("Exception during parsing of request: $e");
      res.statusCode = HttpStatus.badRequest;
      return '{"error": "$e"}';
    }
    // notification
    var notificationTimeout = DateTime.now().difference(requestExpirationTime).inSeconds;
    createNotification(timeoutSeconds: notificationTimeout, title: "Alp auth request from $host");

    // response
    res.headers.contentType = ContentType.json;
    return '{"encryptedMessage":"authenticated-true-json"}';
  });

  await app.listen(await restApiPort());
}
