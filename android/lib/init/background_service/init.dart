import 'package:flutter_background_service/flutter_background_service.dart';

import '../../logging/background_service/logging.dart';
import '../../logging/background_service/logging.dart' as logging;
import '../../rest_api_server/rest_api_server.dart' as rest_api_server;
import '../../notifications/notifications.dart' as notifications;

Future<void> init(ServiceInstance service) async {
  await logging.init(service);
  log.info("initializing background service");
  await notifications.initForBackgroundService();
  await rest_api_server.init();
  log.info("initialized background service");
}