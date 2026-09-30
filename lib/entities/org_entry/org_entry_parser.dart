import 'package:org_parser/org_parser.dart';

import 'entry_edit.dart';
import 'org_entry.dart';
import 'org_entry_locator.dart';

final _whitespaceRegExp = RegExp(r'\s+');
final _timestampRegExp = RegExp(r'[\s]?[<][0-9]{4}-[0-9]{2}-[0-9]{2}.*?[>]');

List<OrgEntry> parseEntriesFromDocument(
  String filePath,
  String fileHash,
  OrgDocument document,
  Set<String> ignoredTodoStates,
) {
  final List<OrgEntry> entries = [];

  visitSections(document, (section, ancestors, locator) {
    final isIgnored =
        section.headline.keyword != null &&
        ignoredTodoStates.contains(section.headline.keyword?.value);
    if (isIgnored) return;

    final tags = [
      ...ancestors.expand((ancestor) => ancestor.tags),
      ...section.tags,
    ];

    final event = _extractEventFromSection(
      section,
      filePath,
      fileHash,
      tags,
      locator,
    );
    if (event != null) entries.add(event);
  });

  return entries;
}

OrgEntry? _extractEventFromSection(
  OrgSection section,
  String filePath,
  String fileHash,
  List<String> tags,
  OrgEntryLocator locator,
) {
  final foundTimestamps = _extractTimestamps(section);
  final headline = _sanitizeHeadline(section);
  final planning = _extractPlanningEntries(section);
  final keyword = section.headline.keyword?.value;

  if (foundTimestamps.isEmpty &&
      planning.$1 == null &&
      planning.$2 == null &&
      keyword == null) {
    return null;
  }

  return OrgEntry(
    todoKeyword: keyword,
    locator: locator,
    containsTimestampInHeadline: _containsTimestampInHeadline(section),
    title: headline,
    tags: tags,
    timestamps: foundTimestamps,
    scheduled: planning.$1,
    deadline: planning.$2,
    filePath: filePath,
    fileHash: fileHash,
  );
}

List<OrgTimestamp> allTimestampsOf(OrgSection section) {
  final planning = _extractPlanningEntries(section);
  return [
    ..._extractTimestamps(section),
    if (planning.$1?.value case final OrgTimestamp scheduled) scheduled,
    if (planning.$2?.value case final OrgTimestamp deadline) deadline,
  ];
}

OrgTimestamp? locateTimestamp(
  OrgSection section,
  OrgEntry entry,
  OrgTimestamp timestamp,
) {
  final markup = timestamp.toMarkup();
  bool sameMarkup(OrgTimestamp candidate) => candidate.toMarkup() == markup;

  final occurrence = entry.unifiedTimestamps
      .takeWhile((candidate) => !identical(candidate, timestamp))
      .where(sameMarkup)
      .length;
  final matches = allTimestampsOf(section).where(sameMarkup).toList();

  return occurrence < matches.length ? matches[occurrence] : null;
}

List<(OrgNode, OrgNode)> replacementsFor(
  OrgSection section,
  OrgEntry entry,
  EntryEdit edit,
) {
  final titleNode = section.headline.title;
  if (titleNode == null) return const [];

  // Keep the whitespace between the title and the tags. Without it, org
  // reads the tags as part of the title.
  final padding = RegExp(r'\s*$').stringMatch(titleNode.toMarkup())!;
  final paddingNode = padding.isEmpty ? null : OrgPlainText(padding);
  final headlineTimestamps = titleNode.children.whereType<OrgTimestamp>();

  final replacements = <(OrgNode, OrgNode)>[];
  final target = switch (edit) {
    EntryEdit(:final oldTimestamp?, newTimestamp: _?) => locateTimestamp(
      section,
      entry,
      oldTimestamp,
    ),
    _ => null,
  };

  if (edit.newTitle case final newTitle?) {
    // The title text holds no timestamps, so the headline timestamps go
    // after the new title.
    replacements.add((
      titleNode as OrgNode,
      OrgContent([
        OrgPlainText(newTitle),
        for (final timestamp in headlineTimestamps) ...[
          OrgPlainText(' '),
          if (identical(timestamp, target)) edit.newTimestamp! else timestamp,
        ],
        ?paddingNode,
      ]),
    ));
    if (headlineTimestamps.any((t) => identical(t, target))) {
      return replacements;
    }
  }
  if (target != null) replacements.add((target, edit.newTimestamp!));

  return replacements;
}

List<OrgTimestamp> _extractTimestamps(OrgSection section) {
  final List<OrgTimestamp> foundTimestamps = [];
  final skipped = Set<OrgNode>.identity();
  var ignoreNTimestamps = 0;

  bool visitor(OrgNode node) {
    if (skipped.contains(node)) return true;
    switch (node) {
      // Add all timestamps inside these nodes into the skipped set
      // These timestamps will be handled seperatly.
      case OrgProperty() || OrgDrawer() || OrgPlanningEntry():
        node.visit<OrgTimestamp>(skipped.add);

      case OrgDateRangeTimestamp():
        // ignore the next 2 timestamps, because they will
        // be just part of this range
        ignoreNTimestamps = 2;

        if (node.isActive) foundTimestamps.add(node);

      case OrgSimpleTimestamp():
        if (ignoreNTimestamps > 0) {
          ignoreNTimestamps -= 1;
          break;
        }
        if (node.isActive) foundTimestamps.add(node);

      case OrgTimeRangeTimestamp():
        if (node.isActive) foundTimestamps.add(node);
    }
    return true;
  }

  for (final child in _ownChildren(section)) {
    child.visit(visitor);
  }
  return foundTimestamps;
}

bool _containsTimestampInHeadline(OrgSection section) =>
    section.headline.rawTitle?.contains(_timestampRegExp) ?? false;

String _sanitizeHeadline(OrgSection section) =>
    (section.headline.rawTitle ?? '')
        .replaceAll(_timestampRegExp, '')
        .replaceAll(_whitespaceRegExp, ' ')
        .trim();

(OrgPlanningEntry?, OrgPlanningEntry?) _extractPlanningEntries(
  OrgSection section,
) {
  OrgPlanningEntry? scheduled;
  OrgPlanningEntry? deadline;

  for (final child in _ownChildren(section)) {
    child.visit((OrgNode node) {
      if (node case OrgPlanningEntry()) {
        switch (node.keyword.content) {
          case 'SCHEDULED:':
            scheduled = node;
          case 'DEADLINE:':
            deadline = node;
        }
      }
      return true;
    });
  }

  return (scheduled, deadline);
}

Iterable<OrgNode> _ownChildren(OrgSection section) =>
    section.children.takeWhile((child) => child is! OrgSection);
