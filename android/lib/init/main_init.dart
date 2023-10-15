import 'package:flutter/material.dart';

import '../logging/logging.dart';
import '../logging/logging.dart' as logging;
import '../background_service/background_service.dart' as background_service;
import '../notifications/notifications.dart' as notifications;

Future<void> init() async {
  await logging.init();
  log.info("initializing main ui isolate");
  WidgetsFlutterBinding.ensureInitialized();
  await notifications.init();
  await background_service.init();
  log.info("initialized main ui isolate");
}