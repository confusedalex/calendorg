import 'dart:isolate';

import 'package:org_parser/org_parser.dart';
import 'package:petitparser/petitparser.dart';

import '../../todo_states_cubit.dart';

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

class _CacheInvalidateMessage {
  const _CacheInvalidateMessage();
}

class OrgParserService {
  bool _started = false;
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
      print('OrgParserService worker isolate started');
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

    print(
      'Sending parse request (${content.length} chars, states: '
      '${todoStates.todo} / ${todoStates.done})',
    );

    _workerSendPort.send(
      _ParseRequest(
        replyPort: responsePort.sendPort,
        content: content,
        todoStates: todoStates.todo,
        doneStates: todoStates.done,
      ),
    );

    try {
      final response = await responsePort.first.timeout(const Duration(seconds: 30));

      if (response is OrgDocument) return response;
      if (response is String) throw StateError('Worker error: $response');
      throw StateError('Unexpected response type');
    } finally {
      responsePort.close();
    }
  }

  void invalidateCache(OrgTodoStatesWithIgnored newStates) {
    _currentTodoStates = newStates;
    print(
      'Invalidating parser cache, new states: '
      '${newStates.todoStates.todo} / ${newStates.todoStates.done}',
    );
    _workerSendPort.send(const _CacheInvalidateMessage());
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

    if (message is _CacheInvalidateMessage) {
      print('Clearing parser cache (was ${parserCache.length} entries)');
      parserCache.clear();
      return;
    }

    final request = message as _ParseRequest;
    final stopwatch = Stopwatch()..start();

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
      stopwatch.stop();

      print('Parse succeeded in ${stopwatch.elapsedMilliseconds}ms ');
      request.replyPort.send(parseResult.value as OrgDocument);
    } catch (e, stack) {
      stopwatch.stop();
      print(
        'Parse failed after ${stopwatch.elapsedMilliseconds}ms: $e\n$stack',
      );
      request.replyPort.send('Parser worker failed: $e');
    }
  });
}
