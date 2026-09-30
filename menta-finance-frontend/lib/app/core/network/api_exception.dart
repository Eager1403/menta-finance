/// Exception inayotolewa na [ApiClient] kila request itakaposhindwa.
/// Inabeba [statusCode] na [message] (kutoka `error` ya backend, au
/// kutoka field-errors za validation - angalia GlobalExceptionHandler
/// upande wa Spring Boot).
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({required this.message, this.statusCode});

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}
