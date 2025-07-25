import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';
import 'package:test/test.dart';

void main() {
  final newTimestamp = OrgSimpleTimestamp("<",
      (year: "2025", month: "05", day: "16", dayName: null), null, [], ">");
  late Event event;
  late OrgTimestamp timestamp;

  setUp(() {
    final document = OrgDocument.parse("* Math exam <2025-05-15>");
    event = parseEvents(FakeFileInfo(), document).entries.first.value.first;
    timestamp = event.timestamps.first;
  });

  group(
    "Event View Bloc",
    () {
      blocTest(
        "Chaning title works",
        build: () => EventViewBloc(event, timestamp),
        act: (bloc) => bloc.add(EventViewTitleChangeEvent("History exam")),
        expect: () => [
          TypeMatcher<EventViewState>()
              .having((state) => state.title, "Title", equals("History exam"))
        ],
      );

      blocTest<EventViewBloc, EventViewState>(
        'emits correct timestamp when Timestamp is changed',
        build: () => EventViewBloc(event, timestamp),
        act: (bloc) => bloc.add(EventViewChangeTimestamp(newTimestamp)),
        expect: () => [
          TypeMatcher<EventViewState>().having(
              (state) => state.timestamp, "timestamp", equals(newTimestamp))
        ],
      );
    },
  );
}

class FakeFileInfo extends Fake implements FileInfo {
  @override
  String get identifier => "MockIdentifier";
}
