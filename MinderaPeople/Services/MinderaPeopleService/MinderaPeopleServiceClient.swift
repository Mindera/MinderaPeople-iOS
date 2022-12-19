import Dependencies

public struct MinderaPeopleServiceClient {
    public var user: @Sendable () async throws -> User
}

extension DependencyValues {
    var minderaPeopleService: MinderaPeopleServiceClient {
        get { self[MinderaPeopleServiceClient.self] }
        set { self[MinderaPeopleServiceClient.self] = newValue }
    }
}
