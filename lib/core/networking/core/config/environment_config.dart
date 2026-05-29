import '../network/logger/network_logger.dart';

/// Environment Configuration
/// Uygulama ortamı için kapsamlı konfigürasyon
class EnvironmentConfig {
  final String baseUrl;
  final String environment;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final LogLevel logLevel;
  final bool isDevelopment;
  final Map<String, dynamic>? defaultHeaders;
  final int? maxRetries;
  final Duration? retryBaseDelay;

  EnvironmentConfig({
    required this.baseUrl,
    required this.environment,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLogging = false,
    this.logLevel = LogLevel.info,
    this.defaultHeaders,
    this.maxRetries = 3,
    this.retryBaseDelay = const Duration(seconds: 1),
  }) : isDevelopment = environment == 'development';

  /// Development ortamı için preset
  factory EnvironmentConfig.development({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
  }) {
    return EnvironmentConfig(
      baseUrl: baseUrl,
      environment: 'development',
      enableLogging: true,
      logLevel: LogLevel.debug,
      defaultHeaders: defaultHeaders,
    );
  }

  /// Production ortamı için preset
  factory EnvironmentConfig.production({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
  }) {
    return EnvironmentConfig(
      baseUrl: baseUrl,
      environment: 'production',
      enableLogging: false,
      logLevel: LogLevel.error,
      defaultHeaders: defaultHeaders,
    );
  }

  /// Staging ortamı için preset
  factory EnvironmentConfig.staging({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
  }) {
    return EnvironmentConfig(
      baseUrl: baseUrl,
      environment: 'staging',
      enableLogging: true,
      logLevel: LogLevel.info,
      defaultHeaders: defaultHeaders,
    );
  }
}
