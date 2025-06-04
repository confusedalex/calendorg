import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/document/document_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';
import 'package:calendorg/features/event_view/event_view.dart';

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
        ),
        BlocProvider(
          create: (context) => EventViewBloc(event, event.timestamps.first),
        )
      ],
      child: EventView(),
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
    },
    skip: true,
  );
}
