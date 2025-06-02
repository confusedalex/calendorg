import 'dart:math';

import 'package:calendorg/event.dart';
import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/pages/calendar/event_card.dart';
import 'package:calendorg/tag_color.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  final markup = """
* Heading 1
** orgmode meetup :meetups:
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
** School :school:
<2025-05-27>
""";
  final document = OrgDocument.parse(markup);
  final event = parseEvents(document).first;
  final meetupTagColor = TagColor("meetups", Colors.pink);
  group('EventCard', () {
    group(
      'EventCard displays correct information',
      () {
        Future<void> initWidget(dynamic tester) async {
          await tester.pumpWidget(MaterialApp(
              home: Scaffold(
            body: BlocProvider<TagColorsCubit>(
              create: (context) =>
                  TagColorsCubit.withInitialValue([meetupTagColor]),
              child: EventCard(event, event.timestamps.first),
            ),
          )));

          await tester.pumpAndSettle();
        }

        testWidgets(
          'EventCard displays correct TagColor',
          (tester) async {
            await initWidget(tester);

            final container = tester.widget<Container>(find.byWidgetPredicate(
                (widget) =>
                    widget is Container &&
                    widget.decoration != null &&
                    widget.decoration is BoxDecoration));

            expect((container.decoration as BoxDecoration).color,
                isSameColorAs(meetupTagColor.color));
          },
        );
        testWidgets("EventCard display correct title", (tester) async {
          await initWidget(tester);

          expect(find.text(event.title), findsOneWidget);
        });

        testWidgets("EventCard display correct time", (tester) async {
          await initWidget(tester);

          expect(find.text(event.timestamps.first.toMarkup()), findsOneWidget);
        });
      },
    );
  });
}
