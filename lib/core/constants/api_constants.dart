class ApiConstants {
  ApiConstants._();

  // GoldAPI.io
  static const String goldApiBaseUrl = 'https://www.goldapi.io/api';
  static const String goldPriceEndpoint = '/XAU/EGP';

  // EODHD
  static const String eodhdBaseUrl = 'https://eodhd.com/api';
  static const String eodhdEodEndpoint = '/eod'; // /eod/{SYMBOL}.{EXCHANGE}

  // Exchange Rate API (free, no key required)
  static const String exchangeRateBaseUrl = 'https://open.er-api.com/v6';
  static const String exchangeRateEndpoint = '/latest/USD';
}
