import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wealth_tracker/features/auth/domain/auth_repository.dart';
import 'package:wealth_tracker/features/settings/domain/settings_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SettingsRepository _settings;
  final LocalAuthentication _localAuth;

  AuthRepositoryImpl(this._settings, this._localAuth);

  static String _hashPin(String pin) =>
      sha256.convert(utf8.encode(pin)).toString();

  @override
  Future<bool> hasPin() async {
    final hash = await _settings.getPinHash();
    return hash != null && hash.isNotEmpty;
  }

  @override
  Future<bool> validatePin(String pin) async {
    final stored = await _settings.getPinHash();
    if (stored == null || stored.isEmpty) return false;
    return _hashPin(pin) == stored;
  }

  @override
  Future<void> setPin(String pin) => _settings.setPinHash(_hashPin(pin));

  @override
  Future<void> clearPin() => _settings.clearPin();

  @override
  Future<bool> isBiometricEnabled() => _settings.getUseBiometric();

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access WealthTracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
