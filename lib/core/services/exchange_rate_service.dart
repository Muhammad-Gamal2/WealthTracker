import 'package:dio/dio.dart';
import 'package:wealth_tracker/core/constants/api_constants.dart';
import 'package:wealth_tracker/core/errors/app_exceptions.dart';

class ExchangeRateService {
  final Dio _dio;

  ExchangeRateService(this._dio);

  /// Fetches current USD -> EGP exchange rate.
  /// Uses the free open.er-api.com endpoint (no key required).
  Future<double> fetchUsdToEgpRate() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exchangeRateBaseUrl}${ApiConstants.exchangeRateEndpoint}',
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final data = response.data as Map<String, dynamic>;

      if (data['result'] != 'success') {
        throw const ApiException('Exchange rate API returned non-success result.');
      }

      final rates = data['rates'] as Map<String, dynamic>;
      final egpRate = rates['EGP'];
      if (egpRate == null) {
        throw const ApiException('EGP rate not found in exchange rate response.');
      }
      return (egpRate as num).toDouble();
    } on DioException catch (e) {
      throw NetworkException(
          e.message ?? 'Failed to fetch USD/EGP exchange rate.');
    }
  }
}
