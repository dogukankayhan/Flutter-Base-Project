import 'package:flutter/services.dart';
import '../domain/entity/device_info_entity.dart';

/// Device Hardware Info Manager
///
/// Provides access to device hardware information without requiring permissions.
/// Information is cached after first call for performance.
///
/// Usage:
/// ```dart
/// final info = await DeviceInfoManager.instance.getDeviceInfo();
/// print('Device: ${info.deviceModel}');
/// print('Battery: ${(info.batteryLevel * 100).toInt()}%');
/// ```
class DeviceInfoManager {
  static const _channel = MethodChannel('com.base.project/device_hardware');

  static DeviceInfoManager? _instance;

  /// Singleton instance
  static DeviceInfoManager get instance {
    _instance ??= DeviceInfoManager._();
    return _instance!;
  }

  DeviceInfoManager._();

  DeviceInfo? _cachedInfo;

  /// Get comprehensive device hardware info
  ///
  /// [forceRefresh] if true, ignores cache and fetches fresh data from native
  /// Useful for getting updated battery level or thermal state
  Future<DeviceInfo> getDeviceInfo({bool forceRefresh = false}) async {
    if (_cachedInfo != null && !forceRefresh) {
      return _cachedInfo!;
    }

    final data = await _channel.invokeMapMethod<String, dynamic>(
      'getDeviceHardwareInfo',
    );

    if (data == null) {
      throw Exception(
        'Failed to get device hardware info from native platform',
      );
    }

    _cachedInfo = DeviceInfo.fromMap(data);
    return _cachedInfo!;
  }

  /// Get current battery level (0.0 - 1.0)
  ///
  /// Uses cached device info. Call with getDeviceInfo(forceRefresh: true)
  /// for up-to-date battery level.
  Future<double> getBatteryLevel({bool forceRefresh = false}) async {
    final info = await getDeviceInfo(forceRefresh: forceRefresh);
    return info.batteryLevel;
  }

  /// Get current thermal state
  ///
  /// Returns: "nominal", "fair", "serious", or "critical"
  Future<String> getThermalState({bool forceRefresh = false}) async {
    final info = await getDeviceInfo(forceRefresh: forceRefresh);
    return info.thermalState;
  }

  /// Check if device supports Face ID (iOS) or face unlock (Android)
  Future<bool> hasFaceID() async {
    final info = await getDeviceInfo();
    return info.faceIDAvailable;
  }

  /// Check if device supports Touch ID (iOS) or fingerprint (Android)
  Future<bool> hasTouchID() async {
    final info = await getDeviceInfo();
    return info.touchIDAvailable;
  }

  /// Get biometry type: "none", "touchID", "faceID", or "fingerprint"
  Future<String> getBiometryType() async {
    final info = await getDeviceInfo();
    return info.biometryType;
  }

  /// Clear cached device info
  ///
  /// Next call to getDeviceInfo() will fetch fresh data from native platform.
  /// Useful when you need updated battery, thermal, or orientation data.
  void clearCache() {
    _cachedInfo = null;
  }

  /// Get formatted device info string for logging/debugging
  Future<String> getDeviceInfoString() async {
    final info = await getDeviceInfo();
    return info.toString();
  }
}
