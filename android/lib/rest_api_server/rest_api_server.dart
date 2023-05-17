import 'dart:io';
import 'package:alfred/alfred.dart';
import '../secure_storage/secure_storage.dart';

Future init() async {
  // Atm. of writing I could not a lib for server-side dart codegen from
  // the openapi.yaml file, hence this is self-written.
  // The openapi.yaml is however used for the client code generation!
  final app = Alfred();

  app.get('/auth', (req, res) {
    res.headers.contentType = ContentType.json;
    return '{"encryptedMessage":"authentiated-true-json"}';
  });

  await app.listen(await restApiPort());
}
