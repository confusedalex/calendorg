import 'dart:io';
import 'dart:ui' as ui;

import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/settings/app_settings.dart';
import 'package:calendorg/core/settings/settings_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/entities/org_entry/org_entry_parser.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:calendorg/main.dart';
import 'package:calendorg/theme.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import 'helpers/preferences.dart';

const _physicalSize = Size(2160, 3840);
const _pixelRatio = 5.25;

const _todoStates = OrgTodoStatesWithIgnored(
  todo: ['TODO', 'NEXT', 'WAITING'],
  done: ['DONE', 'CANCELLED'],
  ignored: [],
);

final _tagColors = [
  TagColor('travel', Colors.purple.shade300),
  TagColor('friends', Colors.pink.shade300),
  TagColor('sport', Colors.teal.shade400),
  TagColor('work', Colors.blue.shade400),
  TagColor('personal', Colors.green.shade400),
  TagColor('study', Colors.orange.shade400),
];

String _ts(int days, [String time = '', String suffix = '']) {
  final now = DateTime.now();
  final date = DateTime(now.year, now.month, now.day + days);
  final ymd = date.toIso8601String().substring(0, 10);
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final parts = [ymd, names[date.weekday - 1], time, suffix];
  return '<${parts.where((p) => p.isNotEmpty).join(' ')}>';
}

String _orgFile() =>
    '''
#+TITLE: Life

* Work                                                                :work:
** NEXT Prepare the sprint review slides
   SCHEDULED: ${_ts(0, '09:00')}
** Team standup
   ${_ts(0, '09:30-09:45', '+1d')}
** WAITING Feedback on the design doc                              :review:
   DEADLINE: ${_ts(1)}
** DONE Deploy v2.3 to production
   SCHEDULED: ${_ts(0, '08:00')}
** Quarterly planning
   ${_ts(2, '13:00-16:00')}
** Onboarding for the new team members
   ${_ts(-6, '10:00')}
** Conference: EmacsConf talk
   ${_ts(-10)}--${_ts(-9)}
** Release retrospective
   ${_ts(12, '15:00')}

* Personal                                                        :personal:
** TODO Call the dentist
   SCHEDULED: ${_ts(0)}
** Dinner with Sam at the new ramen place                         :friends:
   ${_ts(0, '19:30')}
** Climbing session                                                  :sport:
   ${_ts(1, '18:00')}
** Morning run                                                       :sport:
   ${_ts(-3, '07:00')}
** TODO Pay the rent
   DEADLINE: ${_ts(2)}
** Weekend trip to the mountains                                    :travel:
   ${_ts(4)}--${_ts(6)}
** Anna's birthday                                                 :friends:
   ${_ts(9, '', '+1y')}
** Yoga class                                                        :sport:
   ${_ts(-14, '18:00', '+1w')}
** Visit grandma
   ${_ts(-20, '15:00')}
** Book club                                                       :friends:
   ${_ts(-16, '19:00')}
** CANCELLED Car inspection
   SCHEDULED: ${_ts(-2)}

* Study                                                              :study:
** TODO Read chapter 4 of SICP
   SCHEDULED: ${_ts(1)}
** TODO Hand in the homework
   DEADLINE: ${_ts(-8)}
** Org-mode meetup                                                   :emacs:
   ${_ts(3, '18:30')}
** Exam: Distributed systems
   ${_ts(15, '10:00-12:00')}
''';

class _MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class _FakeOrgFilesCubit extends OrgFilesCubit {
  _FakeOrgFilesCubit(OrgFilesState state) : super(_MockOrgFilesRepository()) {
    emit(state);
  }
}

OrgFilesState _filesState() {
  final document =
      OrgParserDefinition(
            todoStates: [_todoStates.todoStates],
          ).build().parse(_orgFile()).value
          as OrgDocument;
  return OrgFilesState(
    directory: DirectoryInfo(
      identifier: 'org',
      persistable: true,
      uri: 'org',
      fileName: 'org',
    ),
    status: OrgFilesStatus.success,
    filePaths: {
      FileInfo(
        identifier: 'life.org',
        persistable: true,
        uri: 'life.org',
        fileName: 'life.org',
      ),
    },
    todoStates: _todoStates,
    entries: parseEntriesFromDocument('life.org', 'hash', document, {}),
  );
}

Future<void> _loadFonts() async {
  final fonts =
      '${Platform.environment['FLUTTER_ROOT']}'
      '/bin/cache/artifacts/material_fonts';
  Future<ByteData> read(String file) async =>
      ByteData.sublistView(await File('$fonts/$file').readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final file in Directory(fonts).listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (name.startsWith('Roboto-')) roboto.addFont(read(name));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('MaterialIcons-Regular.otf'))).load();
}

void main() {
  final screen = GlobalKey();

  setUpAll(_loadFonts);

  Future<void> pumpApp(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    tester.view
      ..physicalSize = _physicalSize
      ..devicePixelRatio = _pixelRatio;
    addTearDown(tester.view.reset);

    // The test binding checks that the flag is true again when the test
    // ends, so snap() resets it.
    debugDisableShadows = false;

    await tester.pumpWidget(
      RepositoryProvider<OrgFilesRepository>(
        create: (_) => _MockOrgFilesRepository(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => SettingsCubit(
                inMemoryPreferences(),
                AppSettings(
                  themeMode: themeMode,
                  tagColors: _tagColors,
                  todoStates: _todoStates,
                ),
              ),
            ),
            BlocProvider<OrgFilesCubit>(
              create: (_) => _FakeOrgFilesCubit(_filesState()),
            ),
          ],
          child: RepaintBoundary(
            key: screen,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              localizationsDelegates:
                  CalendorgLocalizations.localizationsDelegates,
              supportedLocales: CalendorgLocalizations.supportedLocales,
              home: const HomePage(showDebugTab: false),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> snap(WidgetTester tester, String name) async {
    final boundary =
        screen.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(png!.buffer.asUint8List());
    });
    debugDisableShadows = true;
  }

  testWidgets('agenda', (tester) async {
    await pumpApp(tester);
    await snap(tester, '1_agenda');
  });

  testWidgets('calendar', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Calendar');
    await snap(tester, '2_calendar');
  });

  testWidgets('edit event', (tester) async {
    await pumpApp(tester);
    final dinner = find.textContaining('Dinner with Sam', findRichText: true);
    await tester.ensureVisible(dinner);
    await tester.pumpAndSettle();
    await tester.tap(dinner);
    await tester.pumpAndSettle();
    await snap(tester, '3_edit_event');
  });

  testWidgets('tag colors', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Settings');
    await tester.tap(find.text('Tag colors'));
    await tester.pumpAndSettle();
    await snap(tester, '4_tag_colors');
  });

  testWidgets('calendar in dark mode', (tester) async {
    await pumpApp(tester, themeMode: ThemeMode.dark);
    await openTab(tester, 'Calendar');
    await snap(tester, '5_calendar_dark');
  });
}
