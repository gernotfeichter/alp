import '../logging/logging.dart' as logging;
import '../logging/logging.dart';
import '../config/config.dart' as config;
import '../rest_api_server/rest_api_server.dart' as rest_api_server;
import '../notifications/notifications.dart' as notifications;

Future<void> init() async {
  await logging.init();
  log.info("initializing");
  await config.init();
  await rest_api_server.init();
  await notifications.init();
  log.info("initialized");
}