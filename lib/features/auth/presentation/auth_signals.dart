import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/features/auth/domain/auth_repository.dart';

final isUnlockedSignal = signal<bool>(false);
final biometricAvailableSignal = signal<bool>(false);
final hasPinSignal = signal<bool>(false);

Future<void> initAuthState() async {
  final repo = sl<AuthRepository>();
  hasPinSignal.value = await repo.hasPin();
  biometricAvailableSignal.value = await repo.isBiometricAvailable();
  // If no PIN set, consider unlocked
  if (!hasPinSignal.value) {
    isUnlockedSignal.value = true;
  }
}

Future<bool> unlockWithPin(String pin) async {
  final valid = await sl<AuthRepository>().validatePin(pin);
  if (valid) isUnlockedSignal.value = true;
  return valid;
}

Future<bool> unlockWithBiometric() async {
  final success = await sl<AuthRepository>().authenticateWithBiometric();
  if (success) isUnlockedSignal.value = true;
  return success;
}

void lock() => isUnlockedSignal.value = false;
