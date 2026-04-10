abstract class SettingsRepository {
  Future<String?> get(String key);
  Future<void> set(String key, String value);
  Future<void> remove(String key);
  Future<String?> getGoldApiKey();
  Future<void> setGoldApiKey(String key);
  Future<String?> getTwelveDataApiKey();
  Future<void> setTwelveDataApiKey(String key);
  Future<String?> getPinHash();
  Future<void> setPinHash(String hash);
  Future<void> clearPin();
  Future<bool> getUseBiometric();
  Future<void> setUseBiometric(bool value);
  Future<bool> getIsDarkMode();
  Future<void> setIsDarkMode(bool value);
}
