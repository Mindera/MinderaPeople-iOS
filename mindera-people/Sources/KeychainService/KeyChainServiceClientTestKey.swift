import ComposableArchitecture
import XCTestDynamicOverlay

extension KeyChainServiceClient: TestDependencyKey {
    public static let previewValue = Self.noop

    public static let testValue = Self(
        remove: XCTUnimplemented("\(Self.self).remove"),
        update: XCTUnimplemented("\(Self.self).update"),
        load: XCTUnimplemented("\(Self.self).load")
    )
}

extension KeyChainServiceClient {
    public static let noop = Self(
        remove: { _ in },
        update: { _, _ in },
        load: { _ in "12345" }
    )
}
