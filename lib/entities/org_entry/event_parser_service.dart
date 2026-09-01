import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:org_parser/org_parser.dart';

import 'org_entry.dart';

class EventParserService {
  static final _timestampRegExp = RegExp(
    r'[\s]?[<][0-9]{4}-[0-9]{2}-[0-9]{2}.*[>]',
  );

  List<OrgEntryLoaded> parseEntriesFromDocument(
    FileInfo fileInfo,
    OrgDocument document,
    Set<String> ignoredTodoStates,
  ) {
    final List<OrgEntryLoaded> entries = [];

    document.visitSections((section) {
      if (section.headline.keyword != null &&
          ignoredTodoStates.contains(section.headline.keyword?.value)) {
        return true;
      }

      final event = _extractEventFromSection(document, section, fileInfo);
      if (event != null) entries.add(event);

      return true;
    });
    return entries;
  }

  OrgEntryLoaded? _extractEventFromSection(
    OrgDocument document,
    OrgSection section,
    FileInfo fileInfo,
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

    return OrgEntryLoaded(
      todoKeyword: keyword,
      section: section,
      containsTimestampInHeadline: _containsTimestampInHeadline(section),
      fileInfo: fileInfo,
      title: headline,
      tags: section.tagsWithInheritance(document),
      timestamps: foundTimestamps,
      scheduled: planning.$1,
      deadline: planning.$2,
    );
  }

  List<OrgTimestamp> _extractTimestamps(OrgSection section) {
    final List<OrgTimestamp> foundTimestamps = [];
    var returnIfSectionFound = false;
    var ignoreNTimestamps = 0;

    section.visitWithBlacklist({OrgProperty, OrgDrawer, OrgPlanningEntry}, (
      OrgNode node,
    ) {
      switch (node) {
        case OrgSection():
          return !returnIfSectionFound && (returnIfSectionFound = true);

        case OrgDateRangeTimestamp():
          // ignore the next 2 timestamps, because they will
          // be just part of this range
          ignoreNTimestamps = 2;

          if (node.isActive) foundTimestamps.add(node);

        case OrgSimpleTimestamp():
          if (ignoreNTimestamps > 0) break;
          if (node.isActive) foundTimestamps.add(node);

        case OrgTimeRangeTimestamp():
          if (node.isActive) foundTimestamps.add(node);
      }
      return true;
    });
    return foundTimestamps;
  }

  bool _containsTimestampInHeadline(OrgSection section) =>
      section.headline.rawTitle?.contains(_timestampRegExp) ?? false;

  String _sanitizeHeadline(OrgSection section) {
    var headline =
        section.headline.rawTitle?.replaceAll(_timestampRegExp, '') ?? '';

    if (section.tags.isNotEmpty) {
      headline = headline.substring(0, headline.length - 1);
    }

    return headline;
  }

  (OrgPlanningEntry?, OrgPlanningEntry?) _extractPlanningEntries(
    OrgSection section,
  ) {
    OrgPlanningEntry? scheduled;
    OrgPlanningEntry? deadline;

    var returnIfSectionFound = false;

    section.visit((OrgNode node) {
      switch (node) {
        case OrgSection():
          return !returnIfSectionFound && (returnIfSectionFound = true);
        case OrgPlanningEntry():
          switch (node.keyword.content) {
            case 'SCHEDULED:':
              scheduled = node;
            case 'DEADLINE:':
              deadline = node;
          }
      }
      return true;
    });

    return (scheduled, deadline);
  }
}

extension VisitBlacklist on OrgNode {
  bool visitWithBlacklist<T extends OrgNode>(
    Set<Type> blacklist,
    bool Function(T) visitor,
  ) {
    final self = this;
    if (self is T) {
      if (!visitor.call(self)) {
        return false;
      }
    }
    final children = this.children;
    if (children != null) {
      for (final child in children) {
        if (blacklist.contains(child.runtimeType)) continue;
        if (!child.visitWithBlacklist<T>(blacklist, visitor)) return false;
      }
    }
    return true;
  }
}
