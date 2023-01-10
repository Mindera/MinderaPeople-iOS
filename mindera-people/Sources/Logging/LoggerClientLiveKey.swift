import ComposableArchitecture
import AlicerceLogging

extension LoggerClient: DependencyKey {
    public static var liveValue: Self {
        return Self(
            logError: { message in Log.internalLogger.error(message) }
        )
    }
}
