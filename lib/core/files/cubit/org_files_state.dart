part of 'org_files_cubit.dart';

enum OrgFilesStatus { loading, success, failure }

final class OrgFilesState {
  OrgFilesState({
    required this.directory,
    required this.status,
    required this.errors,
    required this.filePaths,
    required this.documentsMap,
    required this.todoStates,
    required this.entries,
    this.inboxFile,
  });

  final DirectoryInfo? directory;
  final OrgFilesStatus status;
  final List<String> errors;
  final Set<FileInfo> filePaths;
  final Map<FileInfo, OrgDocument> documentsMap;
  final FileInfo? inboxFile;
  final OrgTodoStatesWithIgnored todoStates;
  final List<OrgEntry> entries;

  factory OrgFilesState.initial() => OrgFilesState(
    directory: null,
    status: OrgFilesStatus.loading,
    errors: [],
    filePaths: {},
    documentsMap: {},
    todoStates: OrgTodoStatesWithIgnored(
      todo: ['TODO'],
      done: ['DONE'],
      ignored: [],
    ),
    entries: [],
  );

  List<Object?> get props => [filePaths, documentsMap, entries];

  List<Occurrence> occurrencesInRange(DateTimeRange window) =>
      entries
          .expand<Occurrence>((entry) => occurrencesFor(entry, window))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  Future<Map<String, List<Occurrence>>> occurrencesByDateInRange(
    DateTimeRange window,
  ) {
    final map = Isolate.run(() {
      final map = <String, List<Occurrence>>{};
      for (final occurrence in occurrencesInRange(window)) {
        final key = occurrence.date.toIso8601String().split('T')[0];
        (map[key] ??= []).add(occurrence);
      }
      return map;
    });
    return map;
  }

  OrgFilesState copyWith({
    ValueGetter<DirectoryInfo?>? directory,
    OrgFilesStatus? status,
    List<String>? errors,
    Set<FileInfo>? filePaths,
    Map<FileInfo, OrgDocument>? documentsMap,
    OrgTodoStatesWithIgnored? todoStates,
    List<OrgEntry>? entries,
    ValueGetter<FileInfo?>? inboxFile,
  }) {
    return OrgFilesState(
      directory: directory != null ? directory() : this.directory,
      status: status ?? this.status,
      errors: errors ?? this.errors,
      filePaths: filePaths ?? this.filePaths,
      documentsMap: documentsMap ?? this.documentsMap,
      todoStates: todoStates ?? this.todoStates,
      entries: entries ?? this.entries,
      inboxFile: inboxFile != null ? inboxFile() : this.inboxFile,
    );
  }
}
