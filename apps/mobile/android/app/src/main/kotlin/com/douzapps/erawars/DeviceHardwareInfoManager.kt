package com.base.project

import android.app.ActivityManager
import android.content.Context
import android.content.IntentFilter
import android.hardware.Camera
import android.hardware.Sensor
import android.hardware.SensorManager
import android.hardware.biometrics.BiometricManager
import android.media.AudioManager
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.os.StatFs
import android.util.DisplayMetrics
import android.view.WindowManager

class DeviceHardwareInfoManager(private val context: Context) {

    fun getDeviceHardwareInfo(): Map<String, Any?> {
        return mapOf(
            "deviceModel" to Build.MODEL,
            "deviceName" to Build.DEVICE,
            "systemName" to "Android",
            "systemVersion" to Build.VERSION.RELEASE,
            "identifierForVendor" to Build.ID,
            "processorCount" to Runtime.getRuntime().availableProcessors(),
            "physicalMemoryMB" to getPhysicalMemoryMB(),
            "systemUptimeHours" to android.os.SystemClock.elapsedRealtime() / 3600000.0,
            "screenWidth" to getScreenWidth(),
            "screenHeight" to getScreenHeight(),
            "screenScale" to getScreenDensity(),
            "displayGamut" to "sRGB",
            "totalDiskSpaceGB" to getTotalDiskSpaceGB(),
            "freeDiskSpaceGB" to getFreeDiskSpaceGB(),
            "usedDiskSpaceGB" to getUsedDiskSpaceGB(),
            "batteryLevel" to getBatteryLevel(),
            "batteryState" to getBatteryState(),
            "lowPowerModeEnabled" to isPowerSaveMode(),
            "cameraCount" to getCameraCount(),
            "frontCameraAvailable" to hasFrontCamera(),
            "backCameraAvailable" to hasBackCamera(),
            "flashAvailable" to hasFlash(),
            "headphonesConnected" to areHeadphonesConnected(),
            "bluetoothAudioConnected" to isBluetoothAudioConnected(),
            "accelerometerAvailable" to hasSensor(Sensor.TYPE_ACCELEROMETER),
            "gyroscopeAvailable" to hasSensor(Sensor.TYPE_GYROSCOPE),
            "magnetometerAvailable" to hasSensor(Sensor.TYPE_MAGNETIC_FIELD),
            "faceIDAvailable" to false,
            "touchIDAvailable" to hasBiometricSupport(),
            "biometryType" to if (hasBiometricSupport()) "fingerprint" else "none",
            "thermalState" to getThermalState(),
            "deviceOrientation" to "unknown",
            "voiceOverEnabled" to false,
            "reduceMotionEnabled" to false,
            "reduceTransparencyEnabled" to false,
            "manufacturer" to Build.MANUFACTURER,
            "sdkInt" to Build.VERSION.SDK_INT
        )
    }

    // MARK: - Hardware Specifications

    private fun getPhysicalMemoryMB(): Long {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)
        return memInfo.totalMem / 1024 / 1024
    }

    // MARK: - Display Info

    private fun getScreenWidth(): Int {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics)
        return displayMetrics.widthPixels
    }

    private fun getScreenHeight(): Int {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics)
        return displayMetrics.heightPixels
    }

    private fun getScreenDensity(): Float {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics)
        return displayMetrics.density
    }

    // MARK: - Storage Info

    private fun getTotalDiskSpaceGB(): Long {
        val stat = StatFs(Environment.getDataDirectory().path)
        val blockSize = stat.blockSizeLong
        val totalBlocks = stat.blockCountLong
        return (totalBlocks * blockSize) / 1024 / 1024 / 1024
    }

    private fun getFreeDiskSpaceGB(): Long {
        val stat = StatFs(Environment.getDataDirectory().path)
        val blockSize = stat.blockSizeLong
        val availableBlocks = stat.availableBlocksLong
        return (availableBlocks * blockSize) / 1024 / 1024 / 1024
    }

    private fun getUsedDiskSpaceGB(): Long {
        return getTotalDiskSpaceGB() - getFreeDiskSpaceGB()
    }

    // MARK: - Battery Info

    private fun getBatteryLevel(): Float {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val level = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        return level / 100f
    }

    private fun getBatteryState(): String {
        val intentFilter = IntentFilter(android.content.Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = context.registerReceiver(null, intentFilter)
        val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1

        return when (status) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
            BatteryManager.BATTERY_STATUS_FULL -> "full"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "unplugged"
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "unplugged"
            else -> "unknown"
        }
    }

    private fun isPowerSaveMode(): Boolean {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            powerManager.isPowerSaveMode
        } else {
            false
        }
    }

    // MARK: - Camera Info

    @Suppress("DEPRECATION")
    private fun getCameraCount(): Int {
        return try {
            Camera.getNumberOfCameras()
        } catch (e: Exception) {
            0
        }
    }

    @Suppress("DEPRECATION")
    private fun hasFrontCamera(): Boolean {
        val numberOfCameras = Camera.getNumberOfCameras()
        for (i in 0 until numberOfCameras) {
            val info = Camera.CameraInfo()
            Camera.getCameraInfo(i, info)
            if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                return true
            }
        }
        return false
    }

    @Suppress("DEPRECATION")
    private fun hasBackCamera(): Boolean {
        val numberOfCameras = Camera.getNumberOfCameras()
        for (i in 0 until numberOfCameras) {
            val info = Camera.CameraInfo()
            Camera.getCameraInfo(i, info)
            if (info.facing == Camera.CameraInfo.CAMERA_FACING_BACK) {
                return true
            }
        }
        return false
    }

    private fun hasFlash(): Boolean {
        return context.packageManager.hasSystemFeature("android.hardware.camera.flash")
    }

    // MARK: - Audio Info

    private fun areHeadphonesConnected(): Boolean {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
            devices.any { device ->
                device.type == android.media.AudioDeviceInfo.TYPE_WIRED_HEADPHONES ||
                device.type == android.media.AudioDeviceInfo.TYPE_WIRED_HEADSET ||
                device.type == android.media.AudioDeviceInfo.TYPE_USB_HEADSET
            }
        } else {
            @Suppress("DEPRECATION")
            audioManager.isWiredHeadsetOn
        }
    }

    private fun isBluetoothAudioConnected(): Boolean {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
            devices.any { device ->
                device.type == android.media.AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
                device.type == android.media.AudioDeviceInfo.TYPE_BLUETOOTH_SCO
            }
        } else {
            @Suppress("DEPRECATION")
            audioManager.isBluetoothA2dpOn || audioManager.isBluetoothScoOn
        }
    }

    // MARK: - Sensors Info

    private fun hasSensor(sensorType: Int): Boolean {
        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        return sensorManager.getDefaultSensor(sensorType) != null
    }

    // MARK: - Biometric Info

    private fun hasBiometricSupport(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // API 30+ (Android 11+) - use BiometricManager.canAuthenticate(int)
            val biometricManager = context.getSystemService(BiometricManager::class.java)
            val canAuthenticate = biometricManager.canAuthenticate(
                BiometricManager.Authenticators.BIOMETRIC_WEAK
            )
            canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // API 23-29 (Android 6-10) - check fingerprint hardware feature
            context.packageManager.hasSystemFeature("android.hardware.fingerprint")
        } else {
            false
        }
    }

    // MARK: - Thermal State

    private fun getThermalState(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            when (powerManager.currentThermalStatus) {
                PowerManager.THERMAL_STATUS_NONE -> "nominal"
                PowerManager.THERMAL_STATUS_LIGHT -> "fair"
                PowerManager.THERMAL_STATUS_MODERATE -> "fair"
                PowerManager.THERMAL_STATUS_SEVERE -> "serious"
                PowerManager.THERMAL_STATUS_CRITICAL -> "critical"
                PowerManager.THERMAL_STATUS_EMERGENCY -> "critical"
                PowerManager.THERMAL_STATUS_SHUTDOWN -> "critical"
                else -> "nominal"
            }
        } else {
            "nominal"
        }
    }
}
