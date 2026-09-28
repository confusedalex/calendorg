import 'package:calendorg/core/logging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  final log = Logger('LoggingTest');

  setUpAll(setUpLogging);

  test('keeps the message, the error and the stack trace', () {
    log.warning(
      'Error saving file list',
      Exception('disk full'),
      StackTrace.current,
    );

    expect(
      logText,
      allOf(
        contains('WARNING LoggingTest: Error saving file list'),
        contains('Exception: disk full'),
        contains('logging_test.dart'),
      ),
    );
  });

  test('keeps only the last records', () {
    for (var i = 0; i <= maxLogRecords; i++) {
      log.info('record $i');
    }

    expect(logText, isNot(contains('record 0\n')));
    expect(logText, contains('record 1\n'));
    expect(logText, endsWith('record $maxLogRecords'));
  });
}
