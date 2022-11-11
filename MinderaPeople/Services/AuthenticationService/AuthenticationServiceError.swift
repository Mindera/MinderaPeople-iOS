enum AuthenticationServiceError: Error, Equatable {
    case googleSignInFailure(String)
    case noAuthenticationToken
    case noUserFound
    case missingFirebaseClientId
}
