import 'dart:io';
import 'package:alfred/alfred.dart';
import '../secure_storage/secure_storage.dart';

Future init() async {
  // note: atm. of writing I could not a lib for server-side dart codegen from
  // the openapi.yaml file
  final app = Alfred();

  app.get('/auth', (req, res) {
    res.headers.contentType = ContentType.json;
    return '<html><body><h1>Title!</h1></body></html>';
  });

  await app.listen(await restApiPort());
}
