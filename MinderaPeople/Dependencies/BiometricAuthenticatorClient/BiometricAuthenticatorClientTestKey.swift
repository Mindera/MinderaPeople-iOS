import ComposableArchitecture
import XCTestDynamicOverlay

extension DependencyValues {
    public var biometricAuthenticator: BiometricAuthenticatorClient {
        get { self[BiometricAuthenticatorClient.self] }
        set { self[BiometricAuthenticatorClient.self] = newValue }
    }
}

extension BiometricAuthenticatorClient: TestDependencyKey {
    public static let previewValue = Self.noop

    public static let testValue = Self(
        biometricAuthenticationEnabled: XCTUnimplemented("\(Self.self).biometricAuthenticationEnabled"),
        authenticate: XCTUnimplemented("\(Self.self).authenticate"),
        setAuthenticationTimeLimit: XCTUnimplemented("\(Self.self).setAuthenticationTimeLimit"),
        enableBiometricAuthentication: XCTUnimplemented("\(Self.self).enableBiometricAuthentication"),
        updateLastSuccessfulAuthenticationDate: XCTUnimplemented("\(Self.self).updateLastSuccessfulAuthenticationDate")
    )
}

extension BiometricAuthenticatorClient {
    public static let noop = Self(
        biometricAuthenticationEnabled: { true },
        authenticate: { _ in true },
        setAuthenticationTimeLimit: { _ in },
        enableBiometricAuthentication: { _ in },
        updateLastSuccessfulAuthenticationDate: { _ in }
    )
}
