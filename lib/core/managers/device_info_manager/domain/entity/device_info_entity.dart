class DeviceInfo {
  // Basic Device
  final String deviceModel;
  final String deviceName;
  final String systemName;
  final String systemVersion;
  final String? identifierForVendor;

  // Hardware Specs
  final int processorCount;
  final int physicalMemoryMB;
  final double systemUptimeHours;

  // Display
  final double screenWidth;
  final double screenHeight;
  final double screenScale;
  final String displayGamut; // "sRGB" or "P3"

  // Storage
  final int totalDiskSpaceGB;
  final int freeDiskSpaceGB;
  final int usedDiskSpaceGB;

  // Battery
  final double batteryLevel; // 0.0 - 1.0
  final String batteryState; // "unknown", "unplugged", "charging", "full"
  final bool lowPowerModeEnabled;

  // Camera
  final int cameraCount;
  final bool frontCameraAvailable;
  final bool backCameraAvailable;
  final bool flashAvailable;

  // Audio
  final bool headphonesConnected;
  final bool bluetoothAudioConnected;

  // Sensors
  final bool accelerometerAvailable;
  final bool gyroscopeAvailable;
  final bool magnetometerAvailable;

  // Biometric
  final bool faceIDAvailable;
  final bool touchIDAvailable;
  final String biometryType; // "none", "touchID", "faceID", "fingerprint"

  // System State
  final String thermalState; // "nominal", "fair", "serious", "critical"
  final String deviceOrientation;

  // Accessibility
  final bool voiceOverEnabled;
  final bool reduceMotionEnabled;
  final bool reduceTransparencyEnabled;

  // Platform-specific
  final String manufacturer;
  final int? sdkInt; // Android only

  const DeviceInfo({
    required this.deviceModel,
    required this.deviceName,
    required this.systemName,
    required this.systemVersion,
    this.identifierForVendor,
    required this.processorCount,
    required this.physicalMemoryMB,
    required this.systemUptimeHours,
    required this.screenWidth,
    required this.screenHeight,
    required this.screenScale,
    required this.displayGamut,
    required this.totalDiskSpaceGB,
    required this.freeDiskSpaceGB,
    required this.usedDiskSpaceGB,
    required this.batteryLevel,
    required this.batteryState,
    required this.lowPowerModeEnabled,
    required this.cameraCount,
    required this.frontCameraAvailable,
    required this.backCameraAvailable,
    required this.flashAvailable,
    required this.headphonesConnected,
    required this.bluetoothAudioConnected,
    required this.accelerometerAvailable,
    required this.gyroscopeAvailable,
    required this.magnetometerAvailable,
    required this.faceIDAvailable,
    required this.touchIDAvailable,
    required this.biometryType,
    required this.thermalState,
    required this.deviceOrientation,
    required this.voiceOverEnabled,
    required this.reduceMotionEnabled,
    required this.reduceTransparencyEnabled,
    required this.manufacturer,
    this.sdkInt,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceModel: map['deviceModel'] as String? ?? '',
      deviceName: map['deviceName'] as String? ?? '',
      systemName: map['systemName'] as String? ?? '',
      systemVersion: map['systemVersion'] as String? ?? '',
      identifierForVendor: map['identifierForVendor'] as String?,
      processorCount: map['processorCount'] as int? ?? 0,
      physicalMemoryMB: map['physicalMemoryMB'] as int? ?? 0,
      systemUptimeHours: (map['systemUptimeHours'] as num?)?.toDouble() ?? 0.0,
      screenWidth: (map['screenWidth'] as num?)?.toDouble() ?? 0.0,
      screenHeight: (map['screenHeight'] as num?)?.toDouble() ?? 0.0,
      screenScale: (map['screenScale'] as num?)?.toDouble() ?? 1.0,
      displayGamut: map['displayGamut'] as String? ?? 'sRGB',
      totalDiskSpaceGB: map['totalDiskSpaceGB'] as int? ?? 0,
      freeDiskSpaceGB: map['freeDiskSpaceGB'] as int? ?? 0,
      usedDiskSpaceGB: map['usedDiskSpaceGB'] as int? ?? 0,
      batteryLevel: (map['batteryLevel'] as num?)?.toDouble() ?? 0.0,
      batteryState: map['batteryState'] as String? ?? 'unknown',
      lowPowerModeEnabled: map['lowPowerModeEnabled'] as bool? ?? false,
      cameraCount: map['cameraCount'] as int? ?? 0,
      frontCameraAvailable: map['frontCameraAvailable'] as bool? ?? false,
      backCameraAvailable: map['backCameraAvailable'] as bool? ?? false,
      flashAvailable: map['flashAvailable'] as bool? ?? false,
      headphonesConnected: map['headphonesConnected'] as bool? ?? false,
      bluetoothAudioConnected: map['bluetoothAudioConnected'] as bool? ?? false,
      accelerometerAvailable: map['accelerometerAvailable'] as bool? ?? false,
      gyroscopeAvailable: map['gyroscopeAvailable'] as bool? ?? false,
      magnetometerAvailable: map['magnetometerAvailable'] as bool? ?? false,
      faceIDAvailable: map['faceIDAvailable'] as bool? ?? false,
      touchIDAvailable: map['touchIDAvailable'] as bool? ?? false,
      biometryType: map['biometryType'] as String? ?? 'none',
      thermalState: map['thermalState'] as String? ?? 'nominal',
      deviceOrientation: map['deviceOrientation'] as String? ?? 'unknown',
      voiceOverEnabled: map['voiceOverEnabled'] as bool? ?? false,
      reduceMotionEnabled: map['reduceMotionEnabled'] as bool? ?? false,
      reduceTransparencyEnabled:
          map['reduceTransparencyEnabled'] as bool? ?? false,
      manufacturer: map['manufacturer'] as String? ?? '',
      sdkInt: map['sdkInt'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceModel': deviceModel,
      'deviceName': deviceName,
      'systemName': systemName,
      'systemVersion': systemVersion,
      'identifierForVendor': identifierForVendor,
      'processorCount': processorCount,
      'physicalMemoryMB': physicalMemoryMB,
      'systemUptimeHours': systemUptimeHours,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'screenScale': screenScale,
      'displayGamut': displayGamut,
      'totalDiskSpaceGB': totalDiskSpaceGB,
      'freeDiskSpaceGB': freeDiskSpaceGB,
      'usedDiskSpaceGB': usedDiskSpaceGB,
      'batteryLevel': batteryLevel,
      'batteryState': batteryState,
      'lowPowerModeEnabled': lowPowerModeEnabled,
      'cameraCount': cameraCount,
      'frontCameraAvailable': frontCameraAvailable,
      'backCameraAvailable': backCameraAvailable,
      'flashAvailable': flashAvailable,
      'headphonesConnected': headphonesConnected,
      'bluetoothAudioConnected': bluetoothAudioConnected,
      'accelerometerAvailable': accelerometerAvailable,
      'gyroscopeAvailable': gyroscopeAvailable,
      'magnetometerAvailable': magnetometerAvailable,
      'faceIDAvailable': faceIDAvailable,
      'touchIDAvailable': touchIDAvailable,
      'biometryType': biometryType,
      'thermalState': thermalState,
      'deviceOrientation': deviceOrientation,
      'voiceOverEnabled': voiceOverEnabled,
      'reduceMotionEnabled': reduceMotionEnabled,
      'reduceTransparencyEnabled': reduceTransparencyEnabled,
      'manufacturer': manufacturer,
      'sdkInt': sdkInt,
    };
  }

  @override
  String toString() {
    return 'DeviceInfo(model: $deviceModel, manufacturer: $manufacturer, '
        'OS: $systemName $systemVersion, memory: ${physicalMemoryMB}MB, '
        'storage: ${totalDiskSpaceGB}GB, battery: ${(batteryLevel * 100).toInt()}%)';
  }
}
