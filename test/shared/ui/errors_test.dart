import 'package:calendorg/core/files/org_files_problem.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:calendorg/shared/ui/errors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupCalendorgLocalizations(const Locale('en'));

  test('names the missing files', () {
    expect(
      const FilesNotFound(['a.org', 'b.org']).message(l10n),
      '2 files not found: a.org, b.org',
    );
  });

  test('names the entry by its title', () {
    expect(
      const EntryNotFound('Exam').message(l10n),
      '"Exam" is no longer in the file.',
    );
  });
}
