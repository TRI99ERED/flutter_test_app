abstract interface class ISharedPreferencesRepository {
  Future<void> clear();

  Future<bool> containsKey(String key);

  Future<bool?> getBool(String key);

  Future<double?> getDouble(String key);

  Future<int?> getInt(String key);

  Future<String?> getString(String key);

  Future<List<String>?> getStringList(String key);

  Future<bool> hasData();

  Future<void> remove(String key);

  Future<void> setBool(String key, bool value);

  Future<void> setDouble(String key, double value);

  Future<void> setInt(String key, int value);

  Future<void> setString(String key, String value);

  Future<void> setStringList(String key, List<String> value);
}
