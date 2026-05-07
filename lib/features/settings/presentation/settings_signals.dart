import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/features/settings/domain/settings_repository.dart';

final goldApiKeySignal = signal<String>('');
final eodhdApiKeySignal = signal<String>('');
final isDarkModeSignal = signal<bool>(false);
final useBiometricSignal = signal<bool>(false);
final hasPinConfiguredSignal = signal<bool>(false);
final settingsSavedSignal = signal<bool>(false);

Future<void> loadSettings() async {
  final repo = sl<SettingsRepository>();
  goldApiKeySignal.value = await repo.getGoldApiKey() ?? '';
  eodhdApiKeySignal.value = await repo.getEodhdApiKey() ?? '';
  isDarkModeSignal.value = await repo.getIsDarkMode();
  useBiometricSignal.value = await repo.getUseBiometric();
  hasPinConfiguredSignal.value =
      (await repo.getPinHash())?.isNotEmpty ?? false;
}

Future<void> saveGoldApiKey(String key) async {
  await sl<SettingsRepository>().setGoldApiKey(key);
  goldApiKeySignal.value = key;
}

Future<void> saveEodhdApiKey(String key) async {
  await sl<SettingsRepository>().setEodhdApiKey(key);
  eodhdApiKeySignal.value = key;
}

Future<void> toggleDarkMode(bool value) async {
  await sl<SettingsRepository>().setIsDarkMode(value);
  isDarkModeSignal.value = value;
}

Future<void> toggleBiometric(bool value) async {
  await sl<SettingsRepository>().setUseBiometric(value);
  useBiometricSignal.value = value;
}
