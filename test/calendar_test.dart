import 'dart:collection';

import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/pages/calendar_page.dart';
import 'package:calendorg/tag_color.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:org_parser/org_parser.dart';
import 'package:provider/provider.dart';

void main() {
  final markup = """
* Heading 1
** orgmode meetup
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
** School :school:
<2025-05-27>
""";
  final document = OrgDocument.parse(markup);
  final events = parseEvents(document);

  testWidgets('Calendar should show marker for every event occurance',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<TagColorsModel>(
            create: (_) => TagColorsModel(), child: CalendarPage(events)),
      ),
    ));
    var consumers = find.byType(Consumer<TagColorsModel>);

    expect(find.descendant(of: consumers, matching: find.byType(DecoratedBox)),
        findsNWidgets(9));
  });

  testWidgets('Calendar respects tag colors from model', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<TagColorsModel>(
            create: (_) => MockTagColorsModel(), child: CalendarPage(events)),
      ),
    ));

    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.orange),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.blue),
        findsNWidgets(8));
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.green),
        findsNothing);
  });
}

class MockTagColorsModel extends Mock implements TagColorsModel {
  final List<TagColor> _tagColors = [TagColor("school", Colors.orange)];

  @override
  UnmodifiableListView<TagColor> get tagColorsFromPrefs =>
      UnmodifiableListView(_tagColors);
}
