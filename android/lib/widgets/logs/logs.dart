import 'package:android/logging/logging.dart';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final logHistoryProvider = Provider<CircularBuffer<LogRecord>>(
        (ref) => history);

class Logs extends ConsumerWidget {
  const Logs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var logHistory = ref.watch(logHistoryProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          ...logHistory.reversed.map(
                  (logRecord) => LogRecordWidget(logRecord: logRecord))
        ],
      ),
    );
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
