part of 'org_files_bloc.dart';

@immutable
sealed class OrgFilesEvent {}

final class OrgFilesInit extends OrgFilesEvent {}

final class OrgFilesAddFilePath extends OrgFilesEvent {
  final FileInfo? fileInfo;
  OrgFilesAddFilePath(this.fileInfo);
}

final class OrgFilesRemoveFilePath extends OrgFilesEvent {
  final FileInfo fileInfo;
  OrgFilesRemoveFilePath(this.fileInfo);
}

final class OrgFilesChangeInboxFileEvent extends OrgFilesEvent {
  final FileInfo? fileInfo;
  OrgFilesChangeInboxFileEvent(this.fileInfo);
}

final class OrgFilesReplaceNode extends OrgFilesEvent {
  final FileInfo fileInfo;
  final OrgNode oldNode;
  final OrgNode newNode;

  OrgFilesReplaceNode(this.fileInfo, this.oldNode, this.newNode);
}

final class OrgFilesChangeTodoStatesEvent extends OrgFilesEvent {
  final OrgTodoStates todoStates;
  OrgFilesChangeTodoStatesEvent(this.todoStates);
}
