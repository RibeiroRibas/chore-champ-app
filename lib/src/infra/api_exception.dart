class ApiException implements Exception {
  ApiException({required this.statusCode, required this.code, this.message});

  final int statusCode;
  final int code;
  final String? message;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, code: $code, message: $message)';
}
