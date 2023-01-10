import ComposableArchitecture
import Foundation

public struct BiometricAuthenticatorClient {
    public var biometricAuthenticationEnabled: @Sendable () -> Bool
    var authenticate: @Sendable (_ force: Bool) async throws -> Bool
    public var setAuthenticationTimeLimit: @Sendable (TimeInterval) async -> Void
    public var enableBiometricAuthentication: @Sendable (Bool) async -> Void
    public var updateLastSuccessfulAuthenticationDate: @Sendable (Date?) async -> Void
    
    public func authenticate(force: Bool = false) async throws -> Bool {
        try await authenticate(force)
    }
}

extension DependencyValues {
    public var biometricAuthenticator: BiometricAuthenticatorClient {
        get { self[BiometricAuthenticatorClient.self] }
        set { self[BiometricAuthenticatorClient.self] = newValue }
    }
}
