part of 'org_files_cubit.dart';

class OrgFilesState {
  OrgFilesState({
    required this.directory,
    required this.filePaths,
    required this.documentsMap,
    required this.todoStates,
    required this.allEvents,
    this.inboxFile,
  });

  final DirectoryInfo? directory;
  final Set<FileInfo> filePaths;
  final Map<FileInfo, OrgDocument> documentsMap;
  final FileInfo? inboxFile;
  final OrgTodoStatesWithIgnored todoStates;
  final Map<String, List<Event>> allEvents;

  factory OrgFilesState.initial() => OrgFilesState(
    directory: null,
    filePaths: {},
    documentsMap: {},
    todoStates: OrgTodoStatesWithIgnored(
      todo: ["TODO"],
      done: ["DONE"],
      ignored: [],
    ),
    allEvents: {},
  );

  List<Object?> get props => [filePaths, documentsMap, allEvents];

  List<Event> eventsByDate(DateTime date) {
    return allEvents[date.toIso8601String().split("T")[0]] ?? [];
  }

  Map<Event, List<OrgTimestamp>> eventsByDateWithTimestamps(DateTime date) =>
      (allEvents[date.toIso8601String().split("T")[0]] ?? []).fold({}, (
        acc,
        cur,
      ) {
        final timestampsByDate = cur.timestampsByDateTime(date);

        return timestampsByDate.isEmpty ? acc : {...acc, cur: timestampsByDate};
      });

  OrgFilesState copyWith({
    ValueGetter<DirectoryInfo?>? directory,
    Set<FileInfo>? filePaths,
    Map<FileInfo, OrgDocument>? documentsMap,
    OrgTodoStatesWithIgnored? todoStates,
    Map<String, List<Event>>? allEvents,
    ValueGetter<FileInfo?>? inboxFile,
  }) {
    return OrgFilesState(
      directory: directory != null ? directory() : this.directory,
      filePaths: filePaths ?? this.filePaths,
      documentsMap: documentsMap ?? this.documentsMap,
      todoStates: todoStates ?? this.todoStates,
      allEvents: allEvents ?? this.allEvents,
      inboxFile: inboxFile != null ? inboxFile() : this.inboxFile,
    );
  }
}
