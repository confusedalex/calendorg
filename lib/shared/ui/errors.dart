import 'package:flutter/material.dart';

import '../../core/files/org_files_problem.dart';
import '../../l10n/calendorg_localizations.dart';
import '../../util.dart';

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        message,
      ),
      backgroundColor: Colors.red,
    ),
  );
}

void showProblem(BuildContext context, OrgFilesProblem problem) =>
    showError(context, problem.message(context.l10n));

extension OrgFilesProblemMessage on OrgFilesProblem {
  String message(CalendorgLocalizations l10n) => switch (this) {
    FileChangedOnDisk() => l10n.error_file_changed_on_disk,
    EntryNotFound(:final title) => l10n.error_entry_not_found(title),
    FilesNotFound(:final names) => l10n.error_files_not_found(
      names.length,
      names.join(', '),
    ),
    FileNotInOrgFolder() => l10n.error_file_not_in_org_folder,
    FileReadFailed() => l10n.error_reading_file,
    SaveFailed() => l10n.error_saving_section,
    InboxFileInAgendaFiles() => l10n.error_inbox_file_to_agenda_files,
    AlreadyInAgendaFiles() => l10n.error_already_in_agenda_files,
  };
}
