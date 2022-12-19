import ComposableArchitecture
import XCTestDynamicOverlay

extension MinderaPeopleServiceClient: TestDependencyKey {
    public static let previewValue = Self.noop

    public static let testValue = Self(
        user: XCTUnimplemented("\(Self.self).user")
    )
}

extension MinderaPeopleServiceClient {
    public static let noop = Self(
        user: { .stub() }
    )
}
