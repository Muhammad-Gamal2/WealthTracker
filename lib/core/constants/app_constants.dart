class AppConstants {
  AppConstants._();

  static const String appName = 'WealthTracker';
  static const String dbName = 'wealth_tracker.db';

  // Default values
  static const int defaultKarat = 24;
  static const String defaultMarket = 'EGX';
  static const String defaultCurrency = 'EGP';

  // Settings keys
  static const String goldApiKeyKey = 'gold_api_key';
  static const String twelveDataApiKeyKey = 'twelve_data_api_key';
  static const String pinHashKey = 'pin_hash';
  static const String useBiometricKey = 'use_biometric';
  static const String isDarkModeKey = 'is_dark_mode';

  // Chart periods
  static const int period30Days = 30;
  static const int period90Days = 90;
  static const int period365Days = 365;
}
