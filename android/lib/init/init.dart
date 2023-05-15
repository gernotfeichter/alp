import '../logging/logging.dart';
import '../logging/logging.dart' as logging;
import '../secure_storage/secure_storage.dart' as secure_storage;
import '../rest_api_server/rest_api_server.dart' as rest_api_server;
import '../notifications/notifications.dart' as notifications;

Future<void> init() async {
  await logging.init();
  log.info("initializing");
  await rest_api_server.init();
  await notifications.init();
  log.info("initialized");
}