import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricResult { success, failed, notAvailable, notEnrolled, lockedOut }

/// Biometric authentication — Face ID, Touch ID, fingerprint.
///
/// Usage:
/// ```dart
/// final result = await BiometricAuth.authenticate(
///   reason: 'Confirm payment',
/// );
/// if (result == BiometricResult.success) proceed();
/// ```
class BiometricAuth {
  BiometricAuth._();

  static final _auth = LocalAuthentication();

  /// Returns true if the device supports biometrics AND has enrolled credentials.
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types.
  static Future<List<BiometricType>> availableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Prompts the user for biometric authentication.
  ///
  /// [reason] is shown in the system prompt — keep it short and clear.
  /// [useErrorDialogs] shows system error dialogs on failure (default true).
  /// [stickyAuth] keeps the prompt alive when the app goes to background.
  static Future<BiometricResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final available = await isAvailable();
      if (!available) {
        final enrolled = await _auth.getAvailableBiometrics();
        return enrolled.isEmpty
            ? BiometricResult.notEnrolled
            : BiometricResult.notAvailable;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      return authenticated ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      return switch (e.code) {
        'LockedOut' || 'PermanentlyLockedOut' => BiometricResult.lockedOut,
        'NotAvailable' => BiometricResult.notAvailable,
        'NotEnrolled' => BiometricResult.notEnrolled,
        _ => BiometricResult.failed,
      };
    }
  }

  /// Cancels an ongoing authentication prompt.
  static Future<void> stopAuthentication() => _auth.stopAuthentication();
}
