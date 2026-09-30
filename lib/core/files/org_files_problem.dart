import '../../entities/org_entry/org_entry.dart';

sealed class OrgFilesProblem implements Exception {
  const OrgFilesProblem();
}

final class FileChangedOnDisk extends OrgFilesProblem {
  const FileChangedOnDisk(this.entries);

  final List<OrgEntry> entries;
}

final class EntryNotFound extends OrgFilesProblem {
  const EntryNotFound(this.title);
  final String title;
}

final class FilesNotFound extends OrgFilesProblem {
  const FilesNotFound(this.names);
  final List<String> names;
}

final class FileNotInOrgFolder extends OrgFilesProblem {
  const FileNotInOrgFolder();
}

final class FileReadFailed extends OrgFilesProblem {
  const FileReadFailed();
}

final class SaveFailed extends OrgFilesProblem {
  const SaveFailed(this.error);
  final Object error;
}

final class InboxFileInAgendaFiles extends OrgFilesProblem {
  const InboxFileInAgendaFiles();
}

final class AlreadyInAgendaFiles extends OrgFilesProblem {
  const AlreadyInAgendaFiles();
}
