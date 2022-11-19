import ComposableArchitecture
import Firebase
import XCTestDynamicOverlay

extension AuthenticationServiceClient: TestDependencyKey {
    public static let previewValue = Self.noop

    public static let testValue = Self(
        signIn: XCTUnimplemented("\(Self.self).signIn"),
        signOut: XCTUnimplemented("\(Self.self).signOut")
    )
}

extension AuthenticationServiceClient {
    public static let noop = Self(
        signIn: { .stub() },
        signOut: { }
    )
}
