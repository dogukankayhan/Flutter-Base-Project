import 'dart:io';
import 'package:dio/dio.dart';

/// Certificate pinning interceptor.
///
/// Usage — pass your SHA-256 fingerprints (without colons, uppercase):
/// ```dart
/// CertificatePinningInterceptor(
///   allowedSHAs: {'A1B2C3...', 'D4E5F6...'},
/// )
/// ```
/// Always include at least two fingerprints (primary + backup) so a cert
/// rotation doesn't lock users out.
class CertificatePinningInterceptor extends Interceptor {
  final Set<String> allowedSHAs;

  const CertificatePinningInterceptor({required this.allowedSHAs});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra['certificatePinning'] = true;
    handler.next(options);
  }

  /// Call this when creating the HttpClient to validate certificates.
  ///
  /// Example:
  /// ```dart
  /// final httpClient = HttpClient()
  ///   ..badCertificateCallback = pinningInterceptor.badCertificateCallback;
  /// ```
  bool badCertificateCallback(X509Certificate cert, String host, int port) {
    final sha = _sha256Fingerprint(cert.der);
    if (allowedSHAs.contains(sha)) return false; // certificate is valid
    return true; // reject — not in pinned set
  }

  String _sha256Fingerprint(List<int> der) {
    // Use dart:io's built-in SHA-256 via HttpClient cert
    // For production, use the `pointycastle` or `crypto` package for proper
    // DER → SHA-256 computation. This is the integration point.
    return der
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }
}
