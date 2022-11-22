import ComposableArchitecture
import Firebase
import XCTestDynamicOverlay

extension AuthenticationServiceClient: TestDependencyKey {
    public static let previewValue = Self.noop

    public static let testValue = Self(
        user: XCTUnimplemented("\(Self.self).user"),
        signIn: XCTUnimplemented("\(Self.self).signIn"),
        signOut: XCTUnimplemented("\(Self.self).signOut")
    )
}

extension AuthenticationServiceClient {
    public static let noop = Self(
        user: { .stub() },
        signIn: { .stub() },
        signOut: { }
    )
}
