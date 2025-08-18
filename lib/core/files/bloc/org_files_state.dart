part of 'org_files_bloc.dart';

class OrgFilesState {
  OrgFilesState(
      {required this.filePaths,
      required this.documentsMap,
      required this.todoStates,
      this.inboxFile});

  final Set<FileInfo> filePaths;
  final Map<FileInfo, OrgDocument> documentsMap;
  final FileInfo? inboxFile;
  final OrgTodoStates todoStates;
  late final Map<String, List<Event>> allEvents =
      documentsMap.entries.fold({}, (e, k) => parseEvents(k.key, k.value));

  factory OrgFilesState.initial() => OrgFilesState(
        filePaths: {},
        documentsMap: {},
        todoStates: OrgTodoStates(done: ["DONE"], todo: ["TODO"]),
      );

  List<Object?> get props => [filePaths, documentsMap];

  List<Event> eventsByDate(DateTime date) {
    return allEvents[date.toIso8601String().split("T")[0]] ?? [];
  }

  Map<Event, List<OrgTimestamp>> eventsByDateWithTimestamps(DateTime date) =>
      (allEvents[date.toIso8601String().split("T")[0]] ?? []).fold({}, (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);

        return timestampsByDate.isEmpty ? acc : {...acc, cur: timestampsByDate};
      });
  OrgFilesState copyWith(
      {Set<FileInfo>? filePaths,
      Map<FileInfo, OrgDocument>? documentsMap,
      OrgTodoStates? todoStates,
      ValueGetter<FileInfo?>? inboxFile,
      List<Event>? allEvents}) {
    return OrgFilesState(
      filePaths: filePaths ?? this.filePaths,
      documentsMap: documentsMap ?? this.documentsMap,
      todoStates: todoStates ?? this.todoStates,
      inboxFile:
          inboxFile != null ? inboxFile() : this.inboxFile,
    );
  }
}
