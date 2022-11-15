import ComposableArchitecture
import Foundation

public struct BiometricAuthenticatorClient {
    public var biometricAuthenticationEnabled: @Sendable () -> Bool
    public var authenticate: @Sendable () async throws -> Bool
    public var setAuthenticationTimeLimit: @Sendable (TimeInterval) async -> Void
    public var enableBiometricAuthentication: @Sendable (Bool) async -> Void
    public var updateLastSuccessfulAuthenticationDate: @Sendable (Date?) async -> Void
}
