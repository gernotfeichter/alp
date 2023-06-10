import 'package:flutter/material.dart';

import '../logging/logging.dart';
import '../logging/logging.dart' as logging;
import '../background_service/background_service.dart' as background_service;
import '../rest_api_server/rest_api_server.dart' as rest_api_server;
import '../notifications/notifications.dart' as notifications;

bool initialized = false;

Future<void> init() async {
  if (!initialized) {
    await logging.init();
    log.info("initializing");
    WidgetsFlutterBinding.ensureInitialized();
    await notifications.init();
    await background_service.init();
    await rest_api_server.init();
    log.info("initialized");
    initialized = true;
  }
}