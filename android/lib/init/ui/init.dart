import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../logging/ui/logging.dart' as logging;
import '../../logging/ui/logging.dart';
import '../../notifications/notifications.dart' as notifications;

Future<void> initUi(FlutterBackgroundService service) async {
  await logging.init(service);
  log.info("initializing ui");
  WidgetsFlutterBinding.ensureInitialized();
  await notifications.initForUi();
  log.info("initialized ui");
}