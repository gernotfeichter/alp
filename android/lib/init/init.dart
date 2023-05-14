import '../logging/logging.dart' as logging;
import '../logging/logging.dart';
import '../notifications/notifications.dart' as notifications;

void init(){
  logging.init();
  notifications.init();
  log.info("initialized");
}