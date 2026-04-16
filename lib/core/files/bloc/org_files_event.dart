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

final class OrgFilesReplaceNodes extends OrgFilesEvent {
  final FileInfo fileInfo;
  final List<(OrgNode oldNode, OrgNode newNode)> replacements;

  OrgFilesReplaceNodes(this.fileInfo, this.replacements);
}

final class OrgFilesChangeTodoStatesEvent extends OrgFilesEvent {
  final OrgTodoStatesWithIgnored todoStates;
  OrgFilesChangeTodoStatesEvent(this.todoStates);
}
