import 'package:dio/dio.dart';
import '../connectivity/network_info.dart';

class ConnectivityInterceptor extends Interceptor {
  final NetworkInfo networkInfo;

  ConnectivityInterceptor({required this.networkInfo});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // ignore: avoid_print
      print('[CONNECTIVITY] Checking connection...');
      // Add timeout to prevent hanging
      final connected = await networkInfo.isConnected
          .timeout(const Duration(seconds: 5));

      // ignore: avoid_print
      print('[CONNECTIVITY] Connected: $connected');
      if (!connected) {
        // ignore: avoid_print
        print('[CONNECTIVITY] Rejecting request - no connection');
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'No internet connection',
          ),
        );
      }
      // ignore: avoid_print
      print('[CONNECTIVITY] Proceeding with request');
      handler.next(options);
    } catch (e) {
      // If connectivity check fails or times out, assume connected
      // and let the actual request fail if there's no connection
      // ignore: avoid_print
      print('[CONNECTIVITY] Check failed: $e - proceeding anyway');
      handler.next(options);
    }
  }
}
