class ApiError {
  final int? statusCode;
  final String message;
  final String? code;
  final String? key; // server-specific error key
  final dynamic raw;

  ApiError({
    this.statusCode,
    required this.message,
    this.code,
    this.key,
    this.raw,
  });

  @override
  String toString() =>
      'ApiError(statusCode: $statusCode, code: $code, key: $key, message: $message)';
}
