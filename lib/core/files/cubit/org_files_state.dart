part of 'org_files_cubit.dart';

enum OrgFilesStatus { loading, success, failure }

final class OrgFilesState {
  OrgFilesState({
    required this.directory,
    required this.status,
    required this.filePaths,
    required this.documentsMap,
    required this.todoStates,
    required this.entries,
    this.inboxFile,
  });

  final DirectoryInfo? directory;
  final OrgFilesStatus status;
  final Set<FileInfo> filePaths;
  final Map<FileInfo, OrgDocument> documentsMap;
  final FileInfo? inboxFile;
  final OrgTodoStatesWithIgnored todoStates;
  final List<OrgEntry> entries;

  factory OrgFilesState.initial() => OrgFilesState(
    directory: null,
    status: OrgFilesStatus.loading,
    filePaths: {},
    documentsMap: {},
    todoStates: OrgTodoStatesWithIgnored(
      todo: ['TODO'],
      done: ['DONE'],
      ignored: [],
    ),
    entries: [],
  );

  OrgFilesState copyWith({
    ValueGetter<DirectoryInfo?>? directory,
    OrgFilesStatus? status,
    Set<FileInfo>? filePaths,
    Map<FileInfo, OrgDocument>? documentsMap,
    OrgTodoStatesWithIgnored? todoStates,
    List<OrgEntry>? entries,
    ValueGetter<FileInfo?>? inboxFile,
  }) {
    return OrgFilesState(
      directory: directory != null ? directory() : this.directory,
      status: status ?? this.status,
      filePaths: filePaths ?? this.filePaths,
      documentsMap: documentsMap ?? this.documentsMap,
      todoStates: todoStates ?? this.todoStates,
      entries: entries ?? this.entries,
      inboxFile: inboxFile != null ? inboxFile() : this.inboxFile,
    );
  }
}
