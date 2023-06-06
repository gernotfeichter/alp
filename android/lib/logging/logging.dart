import 'package:circular_buffer/circular_buffer.dart';
import 'package:logging/logging.dart';

final log = Logger("root");

final history = CircularBuffer<LogRecord>(100);

Future init() async {
  Logger.root.level = Level.INFO; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    history.add(record);
  });
}