import 'package:flutter/services.dart';

class JailbreakDetector {
  static const _channel = MethodChannel('com.base.project/security');

  /// Check if the device is jailbroken (iOS) or rooted (Android)
  static Future<bool> isDeviceCompromised() async {
    try {
      final result = await _channel.invokeMethod<bool>('isJailbroken');
      return result ?? false;
    } catch (e) {
      // If platform method fails, assume device is safe
      return false;
    }
  }
}
