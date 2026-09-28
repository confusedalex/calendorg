import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

const maxLogRecords = 500;

final _records = ListQueue<String>();

String get logText => _records.join('\n');

void setUpLogging() {
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    final text = _format(record);
    debugPrint(text);
    _records.add(text);
    if (_records.length > maxLogRecords) _records.removeFirst();
  });
}

String _format(LogRecord record) {
  final time = record.time.toIso8601String();
  return [
    '$time ${record.level.name} ${record.loggerName}: ${record.message}',
    if (record.error case final error?) '$error',
    if (record.stackTrace case final stackTrace?) '$stackTrace',
  ].join('\n');
}
