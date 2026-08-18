import 'package:calendorg/features/date_picker/model/date_picker_bloc.dart';
import 'package:calendorg/features/date_picker/ui/date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  void handleSave(OrgTimestamp timestamp) => {};
  testWidgets("DatePicker shows startDate Button", (tester) async {
    final OrgSimpleTimestamp timestamp = OrgDocument.parse(
      "<2025-12-04>",
    ).find<OrgSimpleTimestamp>((node) => true)!.node;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) =>
                DatePickerBloc(DatePickerState.initial(timestamp)),
            child: DatePicker(handleSave),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(Key("datepicker_startdatebutton")), findsOne);
  });

  testWidgets("start date button shows datepicker", (tester) async {
    final OrgSimpleTimestamp timestamp = OrgDocument.parse(
      "<2025-12-04>",
    ).find<OrgSimpleTimestamp>((node) => true)!.node;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) =>
                DatePickerBloc(DatePickerState.initial(timestamp)),
            child: DatePicker(handleSave),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(Key("datepicker_startdatebutton")));

    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets("end date button without enddateactive wont show datepicker", (
    tester,
  ) async {
    final OrgSimpleTimestamp timestamp = OrgDocument.parse(
      "<2025-12-04>",
    ).find<OrgSimpleTimestamp>((node) => true)!.node;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) =>
                DatePickerBloc(DatePickerState.initial(timestamp)),
            child: DatePicker(handleSave),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(Key("datepicker_enddatebutton")));

    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsNothing);
  });

  testWidgets("end date button with enddateactive shows datepicker", (
    tester,
  ) async {
    final OrgSimpleTimestamp timestamp = OrgDocument.parse(
      "<2025-12-04>",
    ).find<OrgSimpleTimestamp>((node) => true)!.node;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) =>
                DatePickerBloc(DatePickerState.initial(timestamp)),
            child: DatePicker(handleSave),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(Key("datepicker_enddatecheckbox")));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("datepicker_enddatebutton")));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets("start time button without endtimeactive wont show timepicker", (
    tester,
  ) async {
    final OrgSimpleTimestamp timestamp = OrgDocument.parse(
      "<2025-12-04>",
    ).find<OrgSimpleTimestamp>((node) => true)!.node;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) =>
                DatePickerBloc(DatePickerState.initial(timestamp)),
            child: DatePicker(handleSave),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(Key("datepicker_starttimebutton")));

    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsNothing);
  });

  testWidgets("start time button with endtimeactive shows timepicker", (
    tester,
  ) async {
    final OrgSimpleTimestamp timestamp = OrgDocument.parse(
      "<2025-12-04>",
    ).find<OrgSimpleTimestamp>((node) => true)!.node;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) =>
                DatePickerBloc(DatePickerState.initial(timestamp)),
            child: DatePicker(handleSave),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(Key("datepicker_starttimecheckbox")));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("datepicker_starttimebutton")));
    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsOneWidget);
  });
}
