import Dependencies
import Foundation

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

public struct UserDefaultsClient {
    public var boolForKey: @Sendable (String) -> Bool
    public var dataForKey: @Sendable (String) -> Data?
    public var doubleForKey: @Sendable (String) -> Double
    public var integerForKey: @Sendable (String) -> Int
    public var dateForKey: @Sendable (String) -> Date?
    public var remove: @Sendable (String) async -> Void
    public var setBool: @Sendable (Bool, String) async -> Void
    public var setData: @Sendable (Data?, String) async -> Void
    public var setDouble: @Sendable (Double, String) async -> Void
    public var setInteger: @Sendable (Int, String) async -> Void
    public var setDate: @Sendable (Date?, String) async -> Void
    
    public var isBiometricAuthenticationEnabled: Bool {
        self.boolForKey(biometricAuthenticationEnabled)
    }
    
    public func setBiometricAuthenticationEnabled(_ bool: Bool) async {
        await self.setBool(bool, biometricAuthenticationEnabled)
    }
    
    public var lastBiometricAuthenticationDate: Date? {
        self.dateForKey(lastBiometricAuthenticationDateKey)
    }
    
    public func setLastBiometricAuthenticationDate(_ date: Date?) async {
        await self.setDate(date, lastBiometricAuthenticationDateKey)
    }
}

let biometricAuthenticationEnabled = "biometricAuthenticationEnabled"
let lastBiometricAuthenticationDateKey = "lastBiometricAuthenticationDateKey"
