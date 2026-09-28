import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:org_parser/org_parser.dart';
import 'package:petitparser/petitparser.dart';

import '../../../entities/todo_states/todo_states_ignored.dart';

final _log = Logger('OrgParserService');

class _ParseRequest {
  final SendPort replyPort;
  final String content;
  final List<String> todoStates;
  final List<String> doneStates;

  _ParseRequest({
    required this.replyPort,
    required this.content,
    required this.todoStates,
    required this.doneStates,
  });
}

class OrgParserService {
  var _started = false;
  late SendPort _workerSendPort;
  late OrgTodoStatesWithIgnored _currentTodoStates;

  OrgParserService([OrgTodoStatesWithIgnored? todoStates]) {
    _currentTodoStates =
        todoStates ??
        OrgTodoStatesWithIgnored(todo: ['TODO'], done: ['DONE'], ignored: []);
  }

  Future<void> start() async {
    if (_started) throw StateError('Already started');
    _started = true;

    final readyPort = ReceivePort();

    try {
      await Isolate.spawn(_parserWorkerMain, readyPort.sendPort);
      final sendPort = await readyPort.first as SendPort;
      _workerSendPort = sendPort;
      _log.fine('Worker isolate started');
    } finally {
      readyPort.close();
    }
  }

  Future<OrgDocument> parseContentInBackground(String content) async {
    if (!_started) {
      throw StateError('Call start() before parsing');
    }

    final responsePort = ReceivePort();
    final todoStates = _currentTodoStates.todoStates;

    _log.fine(
      'Sending parse request (${content.length} chars, states: '
      '${todoStates.todo} / ${todoStates.done})',
    );
    final stopwatch = Stopwatch()..start();

    _workerSendPort.send(
      _ParseRequest(
        replyPort: responsePort.sendPort,
        content: content,
        todoStates: todoStates.todo,
        doneStates: todoStates.done,
      ),
    );

    try {
      final response = await responsePort.first.timeout(
        const Duration(seconds: 30),
      );

      if (response is OrgDocument) {
        _log.fine('Parse succeeded in ${stopwatch.elapsedMilliseconds}ms');
        return response;
      }
      if (response case (final String error, final String stack)) {
        _log.warning(
          'Parse failed after ${stopwatch.elapsedMilliseconds}ms',
          error,
          StackTrace.fromString(stack),
        );
        throw StateError('Worker error: $error');
      }
      throw StateError('Unexpected response type');
    } finally {
      responsePort.close();
    }
  }

  // ignore: use_setters_to_change_properties
  void invalidateCache(OrgTodoStatesWithIgnored newStates) {
    _currentTodoStates = newStates;
  }
}

void _parserWorkerMain(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);
  final parserCache = <String, Parser>{};

  receivePort.listen((message) {
    if (message == null) {
      receivePort.close();
      return;
    }

    final request = message as _ParseRequest;
    try {
      final key =
          '${request.todoStates.join(',')}|${request.doneStates.join(',')}';

      final parser =
          parserCache[key] ??
          (parserCache[key] = OrgParserDefinition(
            todoStates: [
              OrgTodoStates(todo: request.todoStates, done: request.doneStates),
            ],
          ).build());
      final parseResult = parser.parse(request.content);
      request.replyPort.send(parseResult.value as OrgDocument);
    } on Exception catch (e, stack) {
      request.replyPort.send(('$e', '$stack'));
    }
  });
}
