import 'package:shared_preferences/shared_preferences.dart';

class PrefKey<T> {
  const PrefKey(this.name);
  final String name;
}

abstract final class PrefKeys {
  static const startingDay = PrefKey<int>('startingDay');
  static const tagColors = PrefKey<String>('tagColors');
  static const inboxFile = PrefKey<String>('inboxFile');
  static const agendaDirectory = PrefKey<String>('agendaDirectory');
  static const agendaFiles = PrefKey<List<String>>('agendaFiles');
  static const entriesCache = PrefKey<List<String>>('entriesCache');
  static const todoStates = PrefKey<String>('todoStates');
  static const doneStates = PrefKey<String>('doneStates');
  static const ignoredStates = PrefKey<String>('ignoredStates');
}

class PreferencesService {
  final _prefs = SharedPreferencesAsync();

  Future<int?> getInt(PrefKey<int> key) => _prefs.getInt(key.name);
  Future<void> setInt(PrefKey<int> key, int value) =>
      _prefs.setInt(key.name, value);

  Future<String?> getString(PrefKey<String> key) => _prefs.getString(key.name);
  Future<void> setString(PrefKey<String> key, String value) =>
      _prefs.setString(key.name, value);

  Future<List<String>?> getStringList(PrefKey<List<String>> key) =>
      _prefs.getStringList(key.name);
  Future<void> setStringList(PrefKey<List<String>> key, List<String> value) =>
      _prefs.setStringList(key.name, value);

  Future<Map<String, Object?>> getAll() => _prefs.getAll();
}
