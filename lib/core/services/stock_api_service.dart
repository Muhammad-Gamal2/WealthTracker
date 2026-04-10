import 'package:dio/dio.dart';
import 'package:wealth_tracker/core/constants/api_constants.dart';
import 'package:wealth_tracker/core/errors/app_exceptions.dart';

class StockApiService {
  final Dio _dio;

  StockApiService(this._dio);

  /// Fetches latest closing prices for a list of API symbols.
  /// EGX symbols should already include the :XCAI suffix.
  /// Returns a map of apiSymbol -> price.
  Future<Map<String, double>> fetchStockPrices(
    List<String> apiSymbols,
    String apiKey,
  ) async {
    if (apiKey.isEmpty) {
      throw const ApiKeyMissingException('Twelve Data');
    }
    if (apiSymbols.isEmpty) return {};

    final results = <String, double>{};

    // Twelve Data free tier allows up to 8 symbols per request
    const batchSize = 8;
    for (var i = 0; i < apiSymbols.length; i += batchSize) {
      final batch =
          apiSymbols.skip(i).take(batchSize).toList();
      final batchResults = await _fetchBatch(batch, apiKey);
      results.addAll(batchResults);
    }
    return results;
  }

  Future<Map<String, double>> _fetchBatch(
    List<String> apiSymbols,
    String apiKey,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.twelveDataBaseUrl}${ApiConstants.stockQuoteEndpoint}',
        queryParameters: {
          'symbol': apiSymbols.join(','),
          'apikey': apiKey,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final data = response.data;
      final results = <String, double>{};

      if (data is! Map<String, dynamic>) return results;

      // Single symbol: response is a flat object with a 'symbol' key
      // Multiple symbols: response is keyed by symbol
      if (data.containsKey('symbol') && data.containsKey('close')) {
        final symbol = data['symbol'] as String?;
        final close = double.tryParse(data['close']?.toString() ?? '');
        if (symbol != null && close != null) {
          // match back to the apiSymbol form (may include :XCAI)
          final matched = apiSymbols.firstWhere(
            (s) => s.toUpperCase().startsWith(symbol.toUpperCase()),
            orElse: () => symbol,
          );
          results[matched] = close;
        }
      } else {
        for (final entry in data.entries) {
          final symbolData = entry.value;
          if (symbolData is Map<String, dynamic>) {
            // Check for error
            if (symbolData['status'] == 'error' ||
                symbolData['code'] != null) {
              continue; // skip invalid symbols silently
            }
            final close =
                double.tryParse(symbolData['close']?.toString() ?? '');
            if (close != null) {
              results[entry.key] = close;
            }
          }
        }
      }
      return results;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ApiException('Invalid Twelve Data API key.',
            statusCode: 401);
      }
      if (e.response?.statusCode == 429) {
        throw const RateLimitException('Twelve Data');
      }
      throw NetworkException(e.message ?? 'Failed to fetch stock prices.');
    }
  }
}
