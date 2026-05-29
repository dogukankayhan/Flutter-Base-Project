import AVFoundation
import CoreMotion
import LocalAuthentication
import SystemConfiguration
import UIKit

// MARK: - Supporting Enums

public enum DisplayGamut: String, Codable {
    case unspecified, sRGB, p3 = "P3"
}

public enum BatteryState: String, Codable {
    case unknown, unplugged, charging, full
}

public enum ThermalState: String, Codable {
    case nominal, fair, serious, critical
}

public enum DeviceOrientation: String, Codable {
    case unknown, portrait, portraitUpsideDown, landscapeLeft, landscapeRight, faceUp, faceDown
}

public struct CameraInfo: Codable {
    public let position: String
    public let hasFlash: Bool
    public let hasTorch: Bool
    public let maxZoomFactor: CGFloat
    public let hasAutoFocus: Bool
}

public struct BiometricInfo: Codable {
    public let faceIDAvailable: Bool
    public let touchIDAvailable: Bool
    public let biometryType: String
    public let biometricAuthAvailable: Bool
}

public struct AccessibilityFeatures: Codable {
    public let voiceOverEnabled: Bool
    public let reduceMotionEnabled: Bool
    public let reduceTransparencyEnabled: Bool
}

// MARK: - Device Hardware Info Manager

public final class DeviceHardwareInfoManager {
    public static let shared = DeviceHardwareInfoManager()
    private let motionManager = CMMotionManager()

    private init() {}

    // MARK: - Public API (No Permissions Required)

    /// Returns device hardware info as Dictionary for Flutter MethodChannel
    public func getDeviceHardwareInfo() -> [String: Any] {
        return [
            "deviceModel": getDeviceModel(),
            "deviceName": getDeviceName(),
            "systemName": getSystemName(),
            "systemVersion": getSystemVersion(),
            "identifierForVendor": getIdentifierForVendor() ?? "",
            "processorCount": getProcessorCount(),
            "physicalMemoryMB": Int(getPhysicalMemory() / 1024 / 1024),
            "systemUptimeHours": getSystemUptime() / 3600,
            "screenWidth": getScreenBounds().width,
            "screenHeight": getScreenBounds().height,
            "screenScale": getScreenScale(),
            "displayGamut": getDisplayGamut().rawValue,
            "totalDiskSpaceGB": Int(getTotalDiskSpace() / 1024 / 1024 / 1024),
            "freeDiskSpaceGB": Int(getFreeDiskSpace() / 1024 / 1024 / 1024),
            "usedDiskSpaceGB": Int(getUsedDiskSpace() / 1024 / 1024 / 1024),
            "batteryLevel": getBatteryLevel(),
            "batteryState": getBatteryState().rawValue,
            "lowPowerModeEnabled": isLowPowerModeEnabled(),
            "cameraCount": getCameraInfo().count,
            "frontCameraAvailable": isFrontCameraAvailable(),
            "backCameraAvailable": isBackCameraAvailable(),
            "flashAvailable": isFlashAvailable(),
            "headphonesConnected": areHeadphonesConnected(),
            "bluetoothAudioConnected": isBluetoothAudioConnected(),
            "accelerometerAvailable": isAccelerometerAvailable(),
            "gyroscopeAvailable": isGyroscopeAvailable(),
            "magnetometerAvailable": isMagnetometerAvailable(),
            "faceIDAvailable": getBiometricInfo().faceIDAvailable,
            "touchIDAvailable": getBiometricInfo().touchIDAvailable,
            "biometryType": getBiometricInfo().biometryType,
            "thermalState": getThermalState().rawValue,
            "deviceOrientation": getDeviceOrientation().rawValue,
            "voiceOverEnabled": getAccessibilityFeatures().voiceOverEnabled,
            "reduceMotionEnabled": getAccessibilityFeatures().reduceMotionEnabled,
            "reduceTransparencyEnabled": getAccessibilityFeatures().reduceTransparencyEnabled,
            "manufacturer": "Apple",
            "sdkInt": NSNull()
        ]
    }

    // MARK: - Basic Device Info

    public func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        return identifier ?? UIDevice.current.model
    }

    public func getDeviceName() -> String {
        return UIDevice.current.name
    }

    public func getSystemName() -> String {
        return UIDevice.current.systemName
    }

    public func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }

    public func getIdentifierForVendor() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }

    // MARK: - Hardware Specifications

    public func getProcessorCount() -> Int {
        return ProcessInfo.processInfo.processorCount
    }

    public func getPhysicalMemory() -> UInt64 {
        return ProcessInfo.processInfo.physicalMemory
    }

    public func getSystemUptime() -> TimeInterval {
        return ProcessInfo.processInfo.systemUptime
    }

    // MARK: - Display Info

    public func getScreenBounds() -> CGRect {
        return UIScreen.main.bounds
    }

    public func getScreenScale() -> CGFloat {
        return UIScreen.main.scale
    }

    public func getDisplayGamut() -> DisplayGamut {
        if #available(iOS 10.0, *) {
            switch UIScreen.main.traitCollection.displayGamut {
            case .P3:
                return .p3
            case .SRGB:
                return .sRGB
            default:
                return .unspecified
            }
        }
        return .unspecified
    }

    // MARK: - Storage Info

    public func getTotalDiskSpace() -> Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else { return 0 }
        return (systemAttributes[.systemSize] as? NSNumber)?.int64Value ?? 0
    }

    public func getFreeDiskSpace() -> Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else { return 0 }
        return (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
    }

    public func getUsedDiskSpace() -> Int64 {
        return getTotalDiskSpace() - getFreeDiskSpace()
    }

    // MARK: - Battery Info

    public func getBatteryLevel() -> Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }

    public func getBatteryState() -> BatteryState {
        UIDevice.current.isBatteryMonitoringEnabled = true
        switch UIDevice.current.batteryState {
        case .unknown:
            return .unknown
        case .unplugged:
            return .unplugged
        case .charging:
            return .charging
        case .full:
            return .full
        @unknown default:
            return .unknown
        }
    }

    public func isLowPowerModeEnabled() -> Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    // MARK: - Camera Info

    public func getCameraInfo() -> [CameraInfo] {
        var cameras: [CameraInfo] = []
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .unspecified
        )

        for device in discoverySession.devices {
            let position: String
            switch device.position {
            case .front:
                position = "front"
            case .back:
                position = "back"
            default:
                position = "unspecified"
            }

            let cameraInfo = CameraInfo(
                position: position,
                hasFlash: device.hasFlash,
                hasTorch: device.hasTorch,
                maxZoomFactor: device.maxAvailableVideoZoomFactor,
                hasAutoFocus: device.isAutoFocusRangeRestrictionSupported
            )

            cameras.append(cameraInfo)
        }

        return cameras
    }

    public func isFrontCameraAvailable() -> Bool {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
    }

    public func isBackCameraAvailable() -> Bool {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    public func isFlashAvailable() -> Bool {
        return AVCaptureDevice.default(for: .video)?.hasFlash ?? false
    }

    // MARK: - Audio Info

    public func areHeadphonesConnected() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute

        for output in currentRoute.outputs {
            if output.portType == .headphones || output.portType == .bluetoothA2DP {
                return true
            }
        }
        return false
    }

    public func isBluetoothAudioConnected() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute

        for output in currentRoute.outputs {
            if output.portType == .bluetoothA2DP || output.portType == .bluetoothHFP {
                return true
            }
        }
        return false
    }

    // MARK: - Sensors Info

    public func isAccelerometerAvailable() -> Bool {
        return motionManager.isAccelerometerAvailable
    }

    public func isGyroscopeAvailable() -> Bool {
        return motionManager.isGyroAvailable
    }

    public func isMagnetometerAvailable() -> Bool {
        return motionManager.isMagnetometerAvailable
    }

    // MARK: - Biometric Info

    public func getBiometricInfo() -> BiometricInfo {
        let context = LAContext()
        var error: NSError?
        let biometricAuthAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        var biometryType = "none"
        var faceIDAvailable = false
        var touchIDAvailable = false

        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                biometryType = "none"
            case .touchID:
                biometryType = "touchID"
                touchIDAvailable = true
            case .faceID:
                biometryType = "faceID"
                faceIDAvailable = true
            case .opticID:
                biometryType = "opticID"
            @unknown default:
                biometryType = "unknown"
            }
        }

        return BiometricInfo(
            faceIDAvailable: faceIDAvailable,
            touchIDAvailable: touchIDAvailable,
            biometryType: biometryType,
            biometricAuthAvailable: biometricAuthAvailable
        )
    }

    // MARK: - Thermal State

    public func getThermalState() -> ThermalState {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal:
            return .nominal
        case .fair:
            return .fair
        case .serious:
            return .serious
        case .critical:
            return .critical
        @unknown default:
            return .nominal
        }
    }

    // MARK: - Accessibility Features

    public func getAccessibilityFeatures() -> AccessibilityFeatures {
        return AccessibilityFeatures(
            voiceOverEnabled: UIAccessibility.isVoiceOverRunning,
            reduceMotionEnabled: UIAccessibility.isReduceMotionEnabled,
            reduceTransparencyEnabled: UIAccessibility.isReduceTransparencyEnabled
        )
    }

    // MARK: - Device Orientation

    public func getDeviceOrientation() -> DeviceOrientation {
        switch UIDevice.current.orientation {
        case .unknown:
            return .unknown
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .faceUp:
            return .faceUp
        case .faceDown:
            return .faceDown
        @unknown default:
            return .unknown
        }
    }
}
