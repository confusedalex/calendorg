import 'package:calendorg/core/tag_colors/tag_model.dart';
import 'package:calendorg/models/document_model.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';
import 'package:calendorg/pages/calendar/event_view.dart';

void main() {
  final markup = """
* orgmode meetup :meetups:
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-01>--<2025-05-03>
""";
  final document = OrgDocument.parse(markup);
  final event = parseEvents(document).first;
  final meetupTagColor = TagColor("meetups", Colors.pink);

  Future<void> initWidget(dynamic tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => TagColorsCubit.withInitialValue(
                  [meetupTagColor],
                )),
        BlocProvider(
          create: (context) => OrgDocumentCubit(document),
        )
      ],
      child: EventView(event, event.timestamps.first),
    ))));

    await tester.pumpAndSettle();
  }

  group(
    'Event View',
    () {
      testWidgets(
        'EventView shows event title',
        (tester) async {
          await initWidget(tester);

          await tester.pumpAndSettle();

          expect(find.byKey(Key("TitleField")), findsOneWidget);
          expect(find.text(event.title), findsOneWidget);
        },
      );

      group(
        'Date Picker',
        () {
          group(
            'DatePickerSimple',
            () {
              testWidgets(
                'EventView shows datepicker when SimpleTimestamp',
                (tester) async {
                  await initWidget(tester);

                  expect(find.byKey(Key("DatePickerSimple")), findsOneWidget);
                },
              );
              testWidgets(
                'DatePickerSimple shows correct date',
                (tester) async {
                  await initWidget(tester);

                  expect(find.text(event.timestamps.first.toMarkup()),
                      findsOneWidget);
                },
              );
            },
          );
        },
      );

      testWidgets(
        'EventView shows datepicker when SimpleTimestamp',
        (tester) async {
          await initWidget(tester);

          expect(find.byKey(Key("DatePickerSimple")), findsOneWidget);
        },
      );
    },
  );
}
