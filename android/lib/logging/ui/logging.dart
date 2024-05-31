import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:logging/logging.dart';
import '../aggregator.dart';
import '../background_service/serialization.dart';

final log = Logger("root");
Stream<Map<String, dynamic>?>? sendLogsToUi;

Future init(FlutterBackgroundService service) async {
    // logs that come from the background service are forwarded to aggregator
    // and thereby to the ui as well
    sendLogsToUi = service.on("sendLogsToUi");
    sendLogsToUi!.listen((event) {
      if (event!["logRecord"] != null) {
        LogRecord logRecord = Jsonify.fromJson(event["logRecord"]);
        addLogToAggregator(logRecord);
      }
    });
  // logs that come from the ui
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    processLogRecordFromUi(record);
  });
}

void processLogRecordFromUi(LogRecord record) {
  // ignore: avoid_print
  print('${record.level.name}: ${record.time}: ${record.message}');
  if (!record.level.name.contains("FINE")) {
      addLogToAggregator(record);
    }
}
