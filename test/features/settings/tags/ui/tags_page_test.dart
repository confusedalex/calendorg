import 'package:calendorg/core/settings/app_settings.dart';
import 'package:calendorg/core/settings/settings_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/features/settings/tags/ui/tags_page.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/preferences.dart';

const schoolTagColor = TagColor('school', Colors.orange);

void main() {
  group('TagsPage', () {
    late SettingsCubit cubit;

    setUp(() {
      cubit = SettingsCubit(
        inMemoryPreferences(),
        const AppSettings(tagColors: [schoolTagColor]),
      );
    });

    Future<void> pumpWidgetToTester(dynamic tester, SettingsCubit cubit) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (context) => cubit,
          child: const MaterialApp(
            localizationsDelegates:
                CalendorgLocalizations.localizationsDelegates,
            supportedLocales: CalendorgLocalizations.supportedLocales,
            home: Scaffold(body: TagsPage()),
          ),
        ),
      );
    }

    testWidgets('creating tag works', (tester) async {
      await pumpWidgetToTester(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'test tag');

      final Offset center = tester.getCenter(find.byType(ColorWheelPicker));
      await tester.timedDragFrom(
        center,
        const Offset(50, 20),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('newtag_savebutton')));
      await tester.pumpAndSettle();

      expect(
        cubit.state.tagColors,
        containsOnce(const TagColor('test tag', Color(0xff043052))),
      );
      expect(cubit.state.tagColors, containsOnce(schoolTagColor));
    });

    testWidgets('deleting tag works', (tester) async {
      await pumpWidgetToTester(tester, cubit);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('school')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edittag_deletebutton')));

      expect(cubit.state.tagColors, isEmpty);
    });

    testWidgets('changing tag color works', (tester) async {
      await pumpWidgetToTester(tester, cubit);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('school')));
      await tester.pumpAndSettle();

      final Offset center = tester.getCenter(find.byType(ColorWheelPicker));
      await tester.timedDragFrom(
        center,
        const Offset(50, 20),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('edittag_savebutton')));
      await tester.pumpAndSettle();

      expect(cubit.state.tagColors, isNot(contains(schoolTagColor)));
      expect(
        cubit.state.tagColors,
        contains(const TagColor('school', Color(0xff523304))),
      );
    });

    testWidgets('Moving tags word', (tester) async {
      const meetupTag = TagColor('meetups', Colors.purple);
      cubit.addTagColor(meetupTag);

      expect(
        cubit.state.tagColors,
        containsAllInOrder([schoolTagColor, meetupTag]),
      );

      await pumpWidgetToTester(tester, cubit);
      await tester.pumpAndSettle();

      await tester.drag(
        find.descendant(
          of: find.byKey(const Key('school')),
          matching: find.byType(ReorderableDragStartListener),
        ),
        const Offset(0, 1000),
      );
      await tester.pumpAndSettle();

      expect(
        cubit.state.tagColors,
        containsAllInOrder([meetupTag, schoolTagColor]),
      );
    });
  });
}
