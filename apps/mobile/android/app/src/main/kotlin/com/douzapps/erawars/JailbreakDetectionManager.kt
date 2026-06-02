package com.base.project

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.io.BufferedReader
import java.io.InputStreamReader

class JailbreakDetectionManager(private val context: Context) {
    fun isRooted(): Boolean {
        return checkForSuBinary() ||
                checkBuildTags() ||
                checkForSuspiciousPackages() ||
                checkForSuspiciousFiles() ||
                checkForSystemPartitionModification()
    }

    private fun checkForSuBinary(): Boolean {
        val suPaths = arrayOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/system/su",
            "/data/local/xbin/su",
            "/data/local/tmp/su",
            "/data/local/su",
            "/system/app/SuperSU.apk",
            "/system/app/SuperUser.apk"
        )

        for (path in suPaths) {
            if (java.io.File(path).exists()) {
                return true
            }
        }

        return checkWhichCommand()
    }

    private fun checkWhichCommand(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("which su")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val line = reader.readLine()
            reader.close()
            line != null && line.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    private fun checkBuildTags(): Boolean {
        // Check if device is built with test-keys (typically indicates rooted/custom ROM)
        return Build.TAGS != null && Build.TAGS.contains("test-keys")
    }

    private fun checkForSuspiciousPackages(): Boolean {
        val suspiciousPackages = arrayOf(
            "com.topjohnwu.magisk",           // Magisk
            "io.magisk.manager",              // Magisk Manager
            "eu.chainfire.supersu",           // SuperSU
            "com.koushikdutta.superuser",     // Superuser
            "com.thirdparty.superuser",       // Superuser variant
            "com.yellowes.su",                // Superuser variant
            "com.noshufou.android.su",        // Superuser variant
            "com.m0narx.su",                  // Superuser variant
            "com.fs0und.xposed",              // Xposed Framework
            "de.robv.android.xposed.installer",
            "com.saurik.substrate",           // Substrate
            "com.devadvance.rootcloak",       // RootCloak
            "com.devadvance.rootcloakplus",   // RootCloak+
            "de.boehmer.secureshell"          // SSH
        )

        val packageManager = context.packageManager

        for (packageName in suspiciousPackages) {
            try {
                packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
                return true
            } catch (e: PackageManager.NameNotFoundException) {
                // Package not found, continue checking
            }
        }

        return false
    }

    private fun checkForSuspiciousFiles(): Boolean {
        val suspiciousFiles = arrayOf(
            "/system/bin/rootcloaker",
            "/system/bin/rootcloaker.jar",
            "/system/lib/libjni_rootcloaker.so",
            "/system/app/Superuser.apk",
            "/system/app/SuperSU.apk",
            "/system/xbin/daemonsu",
            "/system/etc/init.d/99SuperSUDaemon",
            "/dev/com.android.settings",
            "/system/.supersu",
            "/cache/.supersu",
            "/data/.supersu",
            "/.supersu"
        )

        for (file in suspiciousFiles) {
            if (java.io.File(file).exists()) {
                return true
            }
        }

        return false
    }

    private fun checkForSystemPartitionModification(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("mount")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String?
            var foundRW = false

            while (reader.readLine().also { line = it } != null) {
                if (line != null && line!!.contains("/system") && line!!.contains("rw")) {
                    foundRW = true
                    break
                }
            }

            reader.close()
            foundRW
        } catch (e: Exception) {
            false
        }
    }
}
