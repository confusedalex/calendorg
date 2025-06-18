part of 'org_files_bloc.dart';

class OrgFilesState {
  OrgFilesState({required this.filePaths, required this.documentsMap});
  final Set<String> filePaths;
  final Map<String, OrgDocument> documentsMap;

  factory OrgFilesState.initial() => OrgFilesState(
        filePaths: {},
        documentsMap: {},
      );

  OrgFilesState copyWith(
      {Set<String>? filePaths, Map<String, OrgDocument>? documentsMap}) {
    return OrgFilesState(
        filePaths: filePaths ?? this.filePaths,
        documentsMap: documentsMap ?? this.documentsMap);
  }

  List<Object?> get props => [filePaths, documentsMap];

  List<Event> get allEvents =>
      documentsMap.entries.expand((e) => parseEvents(e.key, e.value)).toList();

  List<Event> eventsByDate(DateTime date) => allEvents.fold([], (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);
        return timestampsByDate.isEmpty ? acc : [...acc, cur];
      });

  Map<Event, List<OrgTimestamp>> eventsByDateWithTimestamps(DateTime date) =>
      allEvents.fold({}, (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);

        return timestampsByDate.isEmpty ? acc : {...acc, cur: timestampsByDate};
      });
}
