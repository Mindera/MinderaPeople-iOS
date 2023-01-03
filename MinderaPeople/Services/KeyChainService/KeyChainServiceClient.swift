import Dependencies

public struct KeyChainServiceClient {
    public var remove: @Sendable (KeyChainService.Key) -> Void
    public var update: @Sendable (String, KeyChainService.Key) -> Void
    public var load: @Sendable (KeyChainService.Key) -> String?
}

extension DependencyValues {
    var keyChainService: KeyChainServiceClient {
        get { self[KeyChainServiceClient.self] }
        set { self[KeyChainServiceClient.self] = newValue }
    }
}
