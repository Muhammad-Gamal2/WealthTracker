class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

class ApiException extends AppException {
  final int? statusCode;

  const ApiException(super.message, {super.code, this.statusCode});

  @override
  String toString() =>
      'ApiException: $message (status: $statusCode)${code != null ? ' ($code)' : ''}';
}

class ApiKeyMissingException extends AppException {
  const ApiKeyMissingException(String service)
      : super('API key not configured for $service. Please add it in Settings.');
}

class RateLimitException extends ApiException {
  const RateLimitException(String service)
      : super('Rate limit reached for $service. Using cached data.',
            statusCode: 429);
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error. Please check your connection.'])
      : super(message);
}
