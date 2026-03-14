import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/src/features/app/data/repositories/shared_preferences/ishared_preferences_repository.dart';

class SharedPreferencesRepositoryImpl implements ISharedPreferencesRepository {
  @override
  Future<void> clear() {
    SharedPreferences.getInstance().then((prefs) => prefs.clear());
    return Future.value();
  }

  @override
  Future<bool> containsKey(String key) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.containsKey(key),
    );
  }

  @override
  Future<bool?> getBool(String key) {
    return SharedPreferences.getInstance().then((prefs) => prefs.getBool(key));
  }

  @override
  Future<double?> getDouble(String key) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.getDouble(key),
    );
  }

  @override
  Future<int?> getInt(String key) {
    return SharedPreferences.getInstance().then((prefs) => prefs.getInt(key));
  }

  @override
  Future<String?> getString(String key) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.getString(key),
    );
  }

  @override
  Future<List<String>?> getStringList(String key) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.getStringList(key),
    );
  }

  @override
  Future<bool> hasData() {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.getKeys().isNotEmpty,
    );
  }

  @override
  Future<void> remove(String key) {
    return SharedPreferences.getInstance().then((prefs) => prefs.remove(key));
  }

  @override
  Future<void> setBool(String key, bool value) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool(key, value),
    );
  }

  @override
  Future<void> setDouble(String key, double value) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.setDouble(key, value),
    );
  }

  @override
  Future<void> setInt(String key, int value) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.setInt(key, value),
    );
  }

  @override
  Future<void> setString(String key, String value) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(key, value),
    );
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList(key, value),
    );
  }
}
