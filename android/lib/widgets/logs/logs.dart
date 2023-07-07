import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../logging/aggregator.dart';

final logAggregatorProvider = StreamProvider<CircularBuffer<LogRecord>>((ref) {
  return logStream;
});

class Logs extends ConsumerWidget {
  const Logs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var last100Logs = ref.watch(logAggregatorProvider);
    Iterable<Widget> logLineWidgets = last100Logs.when(
      data: (records) => records.reversed.map(
              (element) => LogRecordWidget(logRecord: element)),
      error: (err, stack) => [Text(err.toString())],
      loading: () => [const CircularProgressIndicator()]
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          ...logLineWidgets
        ],
      ),
    );
  }

  @override
  String toStringShort() {
    return "Logs";
  }
}

class LogRecordWidget extends StatelessWidget {
  final LogRecord logRecord;

  const LogRecordWidget({super.key, required this.logRecord});

  @override
  Widget build(BuildContext context) {
    Icon icon = switch (logRecord.level) {
      Level.SEVERE => const Icon(Icons.cancel_outlined, color: Colors.red),
      Level.WARNING => const Icon(Icons.warning_amber_outlined, color: Colors.yellow),
      _ => const Icon(Icons.info_outline, color: Colors.blue)
    };

    return Column(
      children: [
        const Divider(),
        Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
                flex: 2,
                child: icon
            ),
            Expanded(
                flex: 8,
                child: Text(logRecord.time.toIso8601String().substring(0, 19))
            ),
            Expanded(
                flex: 11,
                child: Text(logRecord.message))
          ],
        ),
      ],
    );
  }
}
