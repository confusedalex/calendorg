import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendorg/features/settings/starting_day_dialog.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  group(
    "starting_day_dialog_test",
    () {
      late StartingDayCubit cubit;

      setUp(() {
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.empty();
        cubit = StartingDayCubit()
          ..changeStartingDayOfWeek(StartingDayOfWeek.friday);
      });

      Future<void> pumpWidgetToTester(dynamic tester) async {
        await tester.pumpWidget(MaterialApp(
            home: BlocProvider(
                create: (context) => cubit,
                child: Scaffold(body: StartingDateDialog()))));
      }

      group("Monday button", () {
        testWidgets(
          'Dialog should contain button for monday',
          (tester) async {
            await pumpWidgetToTester(tester);

            expect(find.text("Monday"), findsOne);
          },
        );
        testWidgets(
          'States changes to monday, when pressing monday',
          (tester) async {
            await pumpWidgetToTester(tester);

            await tester.tap(find.text("Monday"));

            expect(cubit.state, equals(StartingDayOfWeek.monday));
          },
        );
      });

      group("Sunday button", () {
        testWidgets(
          'Dialog should contain button for sunday',
          (tester) async {
            await pumpWidgetToTester(tester);

            expect(find.text("Sunday"), findsOne);
          },
        );
        testWidgets(
          'Dialog should contain button for sunday',
          (tester) async {
            await pumpWidgetToTester(tester);

            await tester.tap(find.text("Sunday"));

            expect(cubit.state, equals(StartingDayOfWeek.sunday));
          },
        );
      });
    },
  );
}
