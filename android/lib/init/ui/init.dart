import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../logging/ui/logging.dart' as logging;
import '../../logging/ui/logging.dart';
import '../../notifications/notifications.dart' as notifications;
import '../../permissions/local_network.dart';

Future<void> initUi(FlutterBackgroundService service) async {
  await logging.init(service);
  log.info("initializing ui");
  WidgetsFlutterBinding.ensureInitialized();
  await notifications.initForUi();
  if (!await requestLocalNetworkPermission()) {
    log.severe("Local network permission was denied. The alp server cannot "
        "receive authentication requests until it is granted in the settings.");
  }
  log.info("initialized ui");
}