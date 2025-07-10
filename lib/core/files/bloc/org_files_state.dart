part of 'org_files_bloc.dart';

class OrgFilesState {
  OrgFilesState(
      {required this.filePaths,
      required this.documentsMap,
      required this.todoStates,
      this.fileToCaptureTo});

  final Set<FileInfo> filePaths;
  final Map<FileInfo, OrgDocument> documentsMap;
  final FileInfo? fileToCaptureTo;
  final OrgTodoStates todoStates;
  late final List<Event> allEvents =
      documentsMap.entries.expand((e) => parseEvents(e.key, e.value)).toList();

  factory OrgFilesState.initial() => OrgFilesState(
        filePaths: {},
        documentsMap: {},
        todoStates: OrgTodoStates(done: ["DONE"], todo: ["TODO"]),
      );

  List<Object?> get props => [filePaths, documentsMap];

  List<Event> eventsByDate(DateTime date) => allEvents.fold([], (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);
        return timestampsByDate.isEmpty ? acc : [...acc, cur];
      });

  Map<Event, List<OrgTimestamp>> eventsByDateWithTimestamps(DateTime date) =>
      allEvents.fold({}, (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);

        return timestampsByDate.isEmpty ? acc : {...acc, cur: timestampsByDate};
      });
  OrgFilesState copyWith(
      {Set<FileInfo>? filePaths,
      Map<FileInfo, OrgDocument>? documentsMap,
      OrgTodoStates? todoStates,
      ValueGetter<FileInfo?>? fileToCaptureTo,
      List<Event>? allEvents}) {
    return OrgFilesState(
      filePaths: filePaths ?? this.filePaths,
      documentsMap: documentsMap ?? this.documentsMap,
      todoStates: todoStates ?? this.todoStates,
      fileToCaptureTo:
          fileToCaptureTo != null ? fileToCaptureTo() : this.fileToCaptureTo,
    );
  }
}
