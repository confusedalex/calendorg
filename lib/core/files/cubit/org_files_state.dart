part of 'org_files_cubit.dart';

enum OrgFilesStatus { loading, success, failure }

final class OrgFilesState {
  OrgFilesState({
    required this.directory,
    required this.status,
    required this.filePaths,
    required this.todoStates,
    required this.entries,
    this.inboxFile,
    this.problem,
  });

  final DirectoryInfo? directory;
  final OrgFilesStatus status;
  final Set<FileInfo> filePaths;
  final FileInfo? inboxFile;
  final OrgTodoStatesWithIgnored todoStates;
  final List<OrgEntry> entries;

  final OrgFilesProblem? problem;

  factory OrgFilesState.initial() => OrgFilesState(
    directory: null,
    status: OrgFilesStatus.loading,
    filePaths: {},
    todoStates: OrgTodoStatesWithIgnored.defaults,
    entries: [],
  );

  OrgFilesState copyWith({
    ValueGetter<DirectoryInfo?>? directory,
    OrgFilesStatus? status,
    Set<FileInfo>? filePaths,
    OrgTodoStatesWithIgnored? todoStates,
    List<OrgEntry>? entries,
    ValueGetter<FileInfo?>? inboxFile,
    OrgFilesProblem? problem,
  }) {
    return OrgFilesState(
      directory: directory != null ? directory() : this.directory,
      status: status ?? this.status,
      filePaths: filePaths ?? this.filePaths,
      todoStates: todoStates ?? this.todoStates,
      entries: entries ?? this.entries,
      inboxFile: inboxFile != null ? inboxFile() : this.inboxFile,
      problem: problem,
    );
  }
}
