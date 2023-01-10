import Foundation
import UserDefaultsClient

public enum UserDefaultsKeys {
    static let biometricAuthenticationEnabled = "biometricAuthenticationEnabled"
    static let lastBiometricAuthenticationDateKey = "lastBiometricAuthenticationDateKey"
}

extension UserDefaultsClient {
    public var isBiometricAuthenticationEnabled: Bool {
        boolForKey(UserDefaultsKeys.biometricAuthenticationEnabled)
    }

    public func setBiometricAuthenticationEnabled(_ bool: Bool) async {
        await setBool(bool, UserDefaultsKeys.biometricAuthenticationEnabled)
    }

    public var lastBiometricAuthenticationDate: Date? {
        dateForKey(UserDefaultsKeys.lastBiometricAuthenticationDateKey)
    }

    public func setLastBiometricAuthenticationDate(_ date: Date?) async {
        await setDate(date, UserDefaultsKeys.lastBiometricAuthenticationDateKey)
    }
}
