import Foundation

class JailbreakDetector {
    static func isJailbroken() -> Bool {
        // Skip jailbreak checks on simulator - always return false
        #if targetEnvironment(simulator)
        return false
        #endif

        // Check for jailbreak-related files and directories
        let jailbreakFiles = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Applications/Icy.app",
            "/Applications/FakeCarrier.app",
            "/Library/MobileSubstrate/DynamicLibraries/",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia/",
            "/private/var/mobile/Library/SBSettings/Themes/",
            "/private/var/stash",
            "/usr/libexec/ssh-keysign",
            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/etc/ssh/sshd_config",
            "/bin/bash",
            "/usr/bin/sudo",
            "/usr/bin/su",
        ]

        for file in jailbreakFiles {
            if FileManager.default.fileExists(atPath: file) {
                return true
            }
        }

        // Check if we can write to system directories (sandbox bypass)
        if canWriteToSystemDirectory() {
            return true
        }

        // Check for Cydia URL scheme
        if canOpenCydiaURL() {
            return true
        }

        // Check for dynamic library injection
        if hasEnvironmentVariableForInjection() {
            return true
        }

        // Check for read access to /etc/apt (indicates jailbreak tools)
        if FileManager.default.fileExists(atPath: "/etc/apt") {
            return true
        }

        return false
    }

    private static func canWriteToSystemDirectory() -> Bool {
        // Skip this check on simulator - they can write to /private/ legitimately
        #if targetEnvironment(simulator)
        return false
        #else
        let testPath = "/private/jailbreak_test_\(UUID().uuidString)"

        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
        #endif
    }

    private static func canOpenCydiaURL() -> Bool {
        guard let url = URL(string: "cydia://package/com.example.package") else {
            return false
        }

        // Check if the URL can be opened (requires shared application instance)
        // In a security context, we just check if Cydia app exists first
        return FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
    }

    private static func hasEnvironmentVariableForInjection() -> Bool {
        // Check for DYLD_INSERT_LIBRARIES which indicates library injection
        return ProcessInfo.processInfo.environment["DYLD_INSERT_LIBRARIES"] != nil
    }
}
