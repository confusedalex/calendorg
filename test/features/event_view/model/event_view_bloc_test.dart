import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/features/event_view/model/event_view_bloc.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';
import 'package:test/test.dart';

class MockOrgFilesCubit extends Mock implements OrgFilesCubit {}

class FakeFileInfo extends Fake implements FileInfo {
  @override
  String get identifier => 'MockIdentifier';
}

void main() {
  final newTimestamp = OrgSimpleTimestamp(
    '<',
    (year: '2025', month: '05', day: '16', dayName: null),
    null,
    [],
    '>',
  );
  late OrgEntry entry;
  late OrgTimestamp timestamp;
  late MockOrgFilesCubit orgFilesCubit;

  setUpAll(() {
    registerFallbackValue(FakeFileInfo());
  });

  setUp(() {
    orgFilesCubit = MockOrgFilesCubit();
    when(
      () => orgFilesCubit.replaceNodes(any(), any()),
    ).thenAnswer((_) async {});
    final document = OrgDocument.parse('* Math exam <2025-05-15>');
    entry = EventParserService()
        .parseEntriesFromDocument(FakeFileInfo(), document, {})
        .first;
    timestamp = entry.timestamps.first;
  });

  group('Event View Bloc', () {
    blocTest(
      'Chaning title works',
      build: () => EventViewBloc(orgFilesCubit, entry, timestamp),
      act: (bloc) => bloc.add(EventViewTitleChangeEvent('History exam')),
      expect: () => [
        TypeMatcher<EventViewState>().having(
          (state) => state.newEvent.title,
          'Title',
          equals('History exam'),
        ),
      ],
    );

    blocTest<EventViewBloc, EventViewState>(
      'emits correct timestamp when Timestamp is changed in title',
      build: () => EventViewBloc(orgFilesCubit, entry, timestamp),
      act: (bloc) => bloc.add(EventViewChangeTimestamp(newTimestamp)),
      expect: () => [
        TypeMatcher<EventViewState>().having(
          (state) => state.newTimestamp,
          'timestamp',
          equals(newTimestamp),
        ),
      ],
    );

    blocTest<EventViewBloc, EventViewState>(
      'emits correct timestamp when Timestamp is changed',
      build: () => EventViewBloc(
        orgFilesCubit,
        EventParserService()
            .parseEntriesFromDocument(
              FakeFileInfo(),
              OrgDocument.parse('''* Math Exam
          <2025-10-10>'''),
              {},
            )
            .first,
        timestamp,
      ),
      act: (bloc) => bloc.add(EventViewChangeTimestamp(newTimestamp)),
      expect: () => [
        TypeMatcher<EventViewState>().having(
          (state) => state.newTimestamp,
          'timestamp',
          equals(newTimestamp),
        ),
      ],
    );

    blocTest<EventViewBloc, EventViewState>(
      'emits correct state when EventViewSaveEvent is triggered',
      build: () => EventViewBloc(orgFilesCubit, entry, timestamp),
      act: (bloc) {
        bloc.add(EventViewTitleChangeEvent('History exam'));
        bloc.add(EventViewChangeTimestamp(newTimestamp));
        bloc.add(EventViewSaveEvent());
      },
      verify: (bloc) {
        verify(() => orgFilesCubit.replaceNodes(any(), any())).called(1);
      },
    );

    blocTest<EventViewBloc, EventViewState>(
      'save does not emit event when no changes',
      build: () => EventViewBloc(orgFilesCubit, entry, timestamp),
      act: (bloc) => bloc.add(EventViewSaveEvent()),
      expect: () => [],
    );
  });
}
