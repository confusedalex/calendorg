import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/pages/settings/tags/tags_page.dart';
import 'package:calendorg/tag_color.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final TagColor schoolTagColor = TagColor("school", Colors.orange);

void main() {
  group(
    'TagsPage',
    () {
      late TagColorsCubit cubit;

      setUp(() {
        SharedPreferences.setMockInitialValues({});
        cubit = TagColorsCubit.withInitialValue([schoolTagColor]);
      });

      Future<void> pumpWidgetToTester(
          dynamic tester, TagColorsCubit cubit) async {
        await tester.pumpWidget(MaterialApp(
            home: BlocProvider(
                create: (context) => cubit,
                child: Scaffold(body: TagsPage()))));
      }

      testWidgets("creating tag works", (tester) async {
        await pumpWidgetToTester(tester, cubit);
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsOneWidget);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), "test tag");

        final Offset center = tester.getCenter(find.byType(ColorWheelPicker));
        await tester.timedDragFrom(
            center, const Offset(50, 20), const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("newtag_savebutton")));
        await tester.pumpAndSettle();

        expect(
            cubit.state, containsOnce(TagColor("test tag", Color(0xff043052))));
        expect(cubit.state, containsOnce(schoolTagColor));
      });

      testWidgets("deleting tag works", (tester) async {
        await pumpWidgetToTester(tester, cubit);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("school")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key("edittag_deletebutton")));

        expect(cubit.state, isEmpty);
      });

      testWidgets("changing tag color works", (tester) async {
        await pumpWidgetToTester(tester, cubit);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("school")));
        await tester.pumpAndSettle();

        final Offset center = tester.getCenter(find.byType(ColorWheelPicker));
        await tester.timedDragFrom(
            center, const Offset(50, 20), const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("edittag_savebutton")));
        await tester.pumpAndSettle();

        expect(cubit.state, isNot(contains(schoolTagColor)));
        expect(cubit.state, contains(TagColor("school", Color(0xff523304))));
      });

      testWidgets("Moving tags word", (tester) async {
        final TagColor meetupTag = TagColor("meetups", Colors.purple);
        cubit.addTagColor(meetupTag);

        expect(cubit.state, containsAllInOrder([schoolTagColor, meetupTag]));

        await pumpWidgetToTester(tester, cubit);
        await tester.pumpAndSettle();

        await tester.drag(
            find.descendant(
                of: find.byKey(Key("school")),
                matching: find.byType(ReorderableDragStartListener)),
            const Offset(0, 1000));
        await tester.pumpAndSettle();

        expect(cubit.state, containsAllInOrder([meetupTag, schoolTagColor]));
      });
    },
  );
}
