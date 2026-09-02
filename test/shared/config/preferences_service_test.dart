import 'package:calendorg/shared/config/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/preferences.dart';

void main() {
  group('PreferencesService', () {
    test('reads back what it writes, for every value type', () async {
      final prefs = inMemoryPreferences();

      await prefs.setInt(PrefKeys.startingDay, 4);
      await prefs.setString(PrefKeys.tagColors, '["a"]');
      await prefs.setStringList(PrefKeys.agendaFiles, ['one.org', 'two.org']);

      expect(await prefs.getInt(PrefKeys.startingDay), 4);
      expect(await prefs.getString(PrefKeys.tagColors), '["a"]');
      expect(await prefs.getStringList(PrefKeys.agendaFiles), [
        'one.org',
        'two.org',
      ]);
    });

    test('reports null for a key that was never written', () async {
      final prefs = inMemoryPreferences();

      expect(await prefs.getInt(PrefKeys.startingDay), isNull);
      expect(await prefs.getString(PrefKeys.inboxFile), isNull);
      expect(await prefs.getStringList(PrefKeys.entriesCache), isNull);
    });

    test('getAll returns every stored value', () async {
      final prefs = inMemoryPreferences({'startingDay': 2, 'inboxFile': 'i'});

      expect(await prefs.getAll(), {'startingDay': 2, 'inboxFile': 'i'});
    });
  });
}
