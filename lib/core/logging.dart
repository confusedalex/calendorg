import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

void setUpLogging() {
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name} ${record.loggerName}: ${record.message}');
    if (record.error case final error?) debugPrint('$error');
    if (record.stackTrace case final stackTrace?) debugPrint('$stackTrace');
  });
}
