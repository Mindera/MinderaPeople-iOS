import ComposableArchitecture
import XCTestDynamicOverlay

extension LoggerClient: TestDependencyKey {
    public static let previewValue = Self.noop

    public static let testValue = Self(
        logError: XCTUnimplemented("\(Self.self).logError")
    )
}

extension LoggerClient {
    public static let noop = Self(
        logError: { _ in }
    )
}
