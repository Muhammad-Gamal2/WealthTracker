class ApiConstants {
  ApiConstants._();

  // GoldAPI.io
  static const String goldApiBaseUrl = 'https://www.goldapi.io/api';
  static const String goldPriceEndpoint = '/XAU/EGP';

  // Twelve Data
  static const String twelveDataBaseUrl = 'https://api.twelvedata.com';
  static const String stockQuoteEndpoint = '/quote';
  static const String egxSuffix = ':XCAI';

  // Exchange Rate API (free, no key required)
  static const String exchangeRateBaseUrl = 'https://open.er-api.com/v6';
  static const String exchangeRateEndpoint = '/latest/USD';
}
