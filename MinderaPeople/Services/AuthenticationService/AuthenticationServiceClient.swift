import Dependencies

public struct AuthenticationServiceClient {
    public var signIn: @Sendable () async throws -> User
    public var signOut: @Sendable () async throws -> Void
}

extension DependencyValues {
    var authenticationService: AuthenticationServiceClient {
        get { self[AuthenticationServiceClient.self] }
        set { self[AuthenticationServiceClient.self] = newValue }
    }
}
