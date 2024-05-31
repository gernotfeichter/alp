import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:logging/logging.dart';
import '../aggregator.dart';
import 'serialization.dart';

// This is called from both, background service as well as ui
// since logs from both the background service as well as the ui should appear
// in the ui.

final log = Logger("root");
Stream<Map<String, dynamic>?>? sendLogsToUi;

Future init(ServiceInstance service) async {
  sendLogsToUi = service.on("sendLogsToUi");
  sendLogsToUi!.listen((event) {
    if (event!["logRecord"] != null) {
      LogRecord logRecord = event["logRecord"];
      addLogToAggregator(logRecord);
    }
  });
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    processLogRecord(record, service);
  });
}

void processLogRecord(LogRecord record, ServiceInstance service) {
  // ignore: avoid_print
  print('${record.level.name}: ${record.time}: ${record.message}');
  if (!record.level.name.contains("FINE")) {
    // sends logs from background service  to the ui
    service.invoke("sendLogsToUi", {"logRecord": record.toJson()});
  }
}
