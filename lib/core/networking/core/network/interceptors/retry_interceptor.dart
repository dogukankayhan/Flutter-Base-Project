import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Retries only idempotent requests (GET/HEAD) with exponential backoff + jitter.
/// If offline, optionally waits until connectivity is restored before retrying.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final bool waitUntilOnline;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 400),
    this.waitUntilOnline = true,
  });

  bool _isIdempotent(String method) =>
      const ['GET', 'HEAD'].contains(method.toUpperCase());

  bool _isRetryable(DioException err) {
    final sc = err.response?.statusCode;
    final type = err.type;
    final retryableType =
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.connectionError ||
        type == DioExceptionType.unknown;
    final serverError = sc != null && sc >= 500;
    return retryableType || serverError;
  }

  Future<void> _waitBackoff(int attempt) async {
    final jitter = (Random().nextDouble() * 0.4) + 0.8; // 0.8x – 1.2x
    final delay = baseDelay * (1 << attempt);
    await Future<void>.delayed(
      Duration(milliseconds: (delay.inMilliseconds * jitter).round()),
    );
  }

  Future<void> _waitUntilOnlineIfNeeded() async {
    if (!waitUntilOnline) return;
    final status = await Connectivity().checkConnectivity();
    final isOnline = !status.contains(ConnectivityResult.none);
    if (isOnline) return;
    // Wait until we get any non-none status
    await Connectivity().onConnectivityChanged.firstWhere(
      (result) => !result.contains(ConnectivityResult.none),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final current = (requestOptions.extra['retries'] as int?) ?? 0;

    if (!_isIdempotent(requestOptions.method) ||
        !_isRetryable(err) ||
        current >= maxRetries) {
      return handler.next(err);
    }

    await _waitUntilOnlineIfNeeded();
    await _waitBackoff(current);

    requestOptions.extra['retries'] = current + 1;

    try {
      final Response response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }
}
