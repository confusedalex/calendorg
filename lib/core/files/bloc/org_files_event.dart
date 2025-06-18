part of 'org_files_bloc.dart';

@immutable
sealed class OrgFilesEvent {}

final class OrgFilesAddFilePath extends OrgFilesEvent {
  final String file;
  OrgFilesAddFilePath(this.file);
}

final class OrgFilesRemoveFilePath extends OrgFilesEvent {
  final String file;
  OrgFilesRemoveFilePath(this.file);
}

final class OrgFilesReplaceNode extends OrgFilesEvent {
  final String filePath;
  final OrgNode oldNode;
  final OrgNode newNode;

  OrgFilesReplaceNode(this.filePath, this.oldNode, this.newNode);
}
