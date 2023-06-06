import 'dart:async';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:logging/logging.dart';

final CircularBuffer<LogRecord> lastLogs = CircularBuffer<LogRecord>(100);
final logStreamController = StreamController<CircularBuffer<LogRecord>>();
final logStream = logStreamController.stream;

addLogToAggregator(LogRecord logRecord) {
  lastLogs.add(logRecord);
  logStreamController.sink.add(lastLogs);
}