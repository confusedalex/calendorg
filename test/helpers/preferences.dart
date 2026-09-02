import 'package:calendorg/shared/config/preferences_service.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

PreferencesService inMemoryPreferences([Map<String, Object>? data]) {
  SharedPreferencesAsyncPlatform.instance = data == null
      ? InMemorySharedPreferencesAsync.empty()
      : InMemorySharedPreferencesAsync.withData(data);
  return PreferencesService();
}
