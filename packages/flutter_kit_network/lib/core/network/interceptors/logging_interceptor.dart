import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Basic, structured logs (avoid leaking sensitive data)
    // You can plug a proper logger here.
    // ignore: avoid_print
    print('[HTTP][REQ] ${options.method} ${options.uri} headers=${options.headers}');
    if (options.data != null) {
      // ignore: avoid_print
      print('[HTTP][REQ][BODY] ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[HTTP][RES] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[HTTP][ERR] ${err.type} ${err.message} url=${err.requestOptions.uri}');
    handler.next(err);
  }
}
