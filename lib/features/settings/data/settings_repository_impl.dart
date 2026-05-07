import 'package:wealth_tracker/core/constants/app_constants.dart';
import 'package:wealth_tracker/core/database/app_database.dart';
import 'package:wealth_tracker/features/settings/domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _db;
  SettingsRepositoryImpl(this._db);

  @override
  Future<String?> get(String key) => _db.getSetting(key);

  @override
  Future<void> set(String key, String value) => _db.setSetting(key, value);

  @override
  Future<void> remove(String key) => _db.deleteSetting(key);

  @override
  Future<String?> getGoldApiKey() => get(AppConstants.goldApiKeyKey);

  @override
  Future<void> setGoldApiKey(String key) =>
      set(AppConstants.goldApiKeyKey, key);

  @override
  Future<String?> getEodhdApiKey() => get(AppConstants.eodhdApiKeyKey);

  @override
  Future<void> setEodhdApiKey(String key) =>
      set(AppConstants.eodhdApiKeyKey, key);

  @override
  Future<String?> getPinHash() => get(AppConstants.pinHashKey);

  @override
  Future<void> setPinHash(String hash) => set(AppConstants.pinHashKey, hash);

  @override
  Future<void> clearPin() => remove(AppConstants.pinHashKey);

  @override
  Future<bool> getUseBiometric() async {
    final val = await get(AppConstants.useBiometricKey);
    return val == 'true';
  }

  @override
  Future<void> setUseBiometric(bool value) =>
      set(AppConstants.useBiometricKey, value.toString());

  @override
  Future<bool> getIsDarkMode() async {
    final val = await get(AppConstants.isDarkModeKey);
    return val == 'true';
  }

  @override
  Future<void> setIsDarkMode(bool value) =>
      set(AppConstants.isDarkModeKey, value.toString());
}
