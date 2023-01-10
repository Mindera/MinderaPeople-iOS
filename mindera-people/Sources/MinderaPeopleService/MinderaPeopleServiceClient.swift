import Dependencies

public struct MinderaPeopleServiceClient {
    public var user: @Sendable (String?) async throws -> User
}

extension DependencyValues {
    public var minderaPeopleService: MinderaPeopleServiceClient {
        get { self[MinderaPeopleServiceClient.self] }
        set { self[MinderaPeopleServiceClient.self] = newValue }
    }
}
