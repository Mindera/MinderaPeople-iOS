import ComposableArchitecture
import Foundation

public struct LoggerClient {
    public var logError: @Sendable (String) -> Void
}

extension DependencyValues {
    public var logger: LoggerClient {
        get { self[LoggerClient.self] }
        set { self[LoggerClient.self] = newValue }
    }
}
