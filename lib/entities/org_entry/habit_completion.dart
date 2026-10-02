import 'package:org_parser/org_parser.dart';

/// Marks the habit in [section] as done at [now], like Emacs does when you
/// set a repeating entry to a done state:
///
/// - Moves every active repeating timestamp to the next repetition.
/// - Sets the `LAST_REPEAT` property.
/// - Adds a `- State "DONE" from "TODO"` note. The note goes into the
///   `LOGBOOK` drawer if the section has one.
///
/// The keyword of the headline does not change.
OrgSection completeHabit(
  OrgSection section, {
  required String doneKeyword,
  required DateTime now,
}) {
  (bool, OrgZipper?) bump(OrgZipper location) {
    final node = location.node;
    if (node is OrgTimestamp && node.isActive && node.repeats) {
      return (true, location.replace(node.bumpRepetition(now)));
    }
    return (true, location);
  }

  final timestamp = OrgSimpleTimestamp(
    '[',
    now.toOrgDate(),
    now.toOrgTime(),
    const [],
    ']',
  );
  final propertyIndent =
      section.content?.find<OrgProperty>((_) => true)?.node.indent ?? '';
  final keyword = section.headline.keyword?.value ?? '';
  // See `org-log-note-headings`: "State %-12s from %-12S %t"
  final note = OrgContent([
    OrgPlainText(
      'State ${'"$doneKeyword"'.padRight(12)} '
      'from ${'"$keyword"'.padRight(12)} ',
    ),
    timestamp,
    OrgPlainText('\n'),
  ]);

  final bumped = section
      .copyWith(
        headline: section.headline.edit().visit(bump).commit<OrgHeadline>(),
        content: section.content?.edit().visit(bump).commit<OrgContent>(),
      )
      .setProperty<OrgSection>(
        OrgProperty(
          propertyIndent,
          ':LAST_REPEAT:',
          ' ',
          OrgContent([timestamp]),
          '\n',
        ),
      );

  final logbook = bumped.content
      ?.find<OrgDrawer>(
        (drawer) => drawer.header.trim().toUpperCase() == ':LOGBOOK:',
      )
      ?.node;
  if (logbook == null) return bumped.addLogNote(note);

  return bumped.copyWith(
    content: bumped.content!
        .editNode(logbook)!
        .replace(_prependNote(logbook, note))
        .commit<OrgContent>(),
  );
}

OrgDrawer _prependNote(OrgDrawer logbook, OrgContent note) {
  final children = logbook.body.children;
  final first = children.firstOrNull;
  final indent = first is OrgList ? first.indent : logbook.indent;
  final item = OrgListUnorderedItem(indent, '- ', null, null, note);

  return logbook.copyWith(
    body: logbook.body.copyWith(
      children: first is OrgList
          ? [
              first.copyWith(items: [item, ...first.items]),
              ...children.skip(1),
            ]
          : [
              OrgList([item], ''),
              ...children,
            ],
    ),
  );
}
