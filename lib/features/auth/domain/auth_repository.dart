abstract class AuthRepository {
  Future<bool> hasPin();
  Future<bool> validatePin(String pin);
  Future<void> setPin(String pin);
  Future<void> clearPin();
  Future<bool> isBiometricEnabled();
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometric();
}
