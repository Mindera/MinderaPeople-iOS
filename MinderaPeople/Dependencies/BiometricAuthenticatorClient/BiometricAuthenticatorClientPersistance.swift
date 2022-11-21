import Foundation

private enum UserDefaultsKeys: String {
    case biometricAuthenticationEnabled
    case lastBiometricAuthenticationDateKey
}

extension UserDefaultsClient {
    public var isBiometricAuthenticationEnabled: Bool {
        boolForKey(UserDefaultsKeys.biometricAuthenticationEnabled.rawValue)
    }

    public func setBiometricAuthenticationEnabled(_ bool: Bool) async {
        await setBool(bool, UserDefaultsKeys.biometricAuthenticationEnabled.rawValue)
    }

    public var lastBiometricAuthenticationDate: Date? {
        dateForKey(UserDefaultsKeys.lastBiometricAuthenticationDateKey.rawValue)
    }

    public func setLastBiometricAuthenticationDate(_ date: Date?) async {
        await setDate(date, UserDefaultsKeys.lastBiometricAuthenticationDateKey.rawValue)
    }
}
