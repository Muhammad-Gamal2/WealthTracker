import 'package:dio/dio.dart';
import 'package:wealth_tracker/core/constants/api_constants.dart';
import 'package:wealth_tracker/core/errors/app_exceptions.dart';

class StockApiService {
  final Dio _dio;

  StockApiService(this._dio);

  /// Fetches latest closing prices for a list of API symbols via EODHD.
  /// Symbols use the format SYMBOL.EXCHANGE (e.g. AMOC.EGX, AAPL.US).
  /// Returns a map of apiSymbol -> price.
  Future<Map<String, double>> fetchStockPrices(
    List<String> apiSymbols,
    String apiKey,
  ) async {
    if (apiKey.isEmpty) {
      throw const ApiKeyMissingException('EODHD');
    }
    if (apiSymbols.isEmpty) return {};

    final results = <String, double>{};
    final futures = <Future<void>>[];

    for (final symbol in apiSymbols) {
      futures.add(
        _fetchSingle(symbol, apiKey).then((price) {
          if (price != null) {
            results[symbol] = price;
          }
        }),
      );
    }

    await Future.wait(futures);
    return results;
  }

  Future<double?> _fetchSingle(String apiSymbol, String apiKey) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.eodhdBaseUrl}${ApiConstants.eodhdEodEndpoint}/$apiSymbol',
        queryParameters: {
          'api_token': apiKey,
          'fmt': 'json',
          'order': 'd',
        },
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final data = response.data;
      if (data is List && data.isNotEmpty) {
        final latest = data.first;
        if (latest is Map<String, dynamic>) {
          final close = (latest['close'] as num?)?.toDouble();
          return close;
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ApiException('Invalid EODHD API key.', statusCode: 401);
      }
      if (e.response?.statusCode == 429) {
        throw const RateLimitException('EODHD');
      }
      throw NetworkException(e.message ?? 'Failed to fetch stock price for $apiSymbol.');
    }
  }
}
