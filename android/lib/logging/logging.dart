import 'dart:async';

import 'package:logging/logging.dart';
import 'aggregator.dart';

final log = Logger("root");

Future init() async {
  Logger.root.level = Level.INFO; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (!record.level.name.contains("FINE")) {
      addLogToAggregator(record);
    }
  });
}