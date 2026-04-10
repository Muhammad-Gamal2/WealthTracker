import 'package:dio/dio.dart';
import 'package:wealth_tracker/core/constants/api_constants.dart';
import 'package:wealth_tracker/core/errors/app_exceptions.dart';

class GoldPriceData {
  final double price24k;
  final double price22k;
  final double price21k;
  final double price18k;

  const GoldPriceData({
    required this.price24k,
    required this.price22k,
    required this.price21k,
    required this.price18k,
  });
}

class GoldApiService {
  final Dio _dio;

  GoldApiService(this._dio);

  Future<GoldPriceData> fetchGoldPrices(String apiKey) async {
    if (apiKey.isEmpty) {
      throw const ApiKeyMissingException('GoldAPI.io');
    }

    try {
      final response = await _dio.get(
        '${ApiConstants.goldApiBaseUrl}${ApiConstants.goldPriceEndpoint}',
        options: Options(
          headers: {
            'x-access-token': apiKey,
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final price24k = (data['price_gram_24k'] as num).toDouble();

      return GoldPriceData(
        price24k: price24k,
        price22k: (data['price_gram_22k'] as num?)?.toDouble() ??
            price24k * (22 / 24),
        price21k: (data['price_gram_21k'] as num?)?.toDouble() ??
            price24k * (21 / 24),
        price18k: (data['price_gram_18k'] as num?)?.toDouble() ??
            price24k * (18 / 24),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ApiException('Invalid GoldAPI key.', statusCode: 401);
      }
      if (e.response?.statusCode == 429) {
        throw const RateLimitException('GoldAPI.io');
      }
      throw NetworkException(e.message ?? 'Failed to fetch gold prices.');
    }
  }
}
