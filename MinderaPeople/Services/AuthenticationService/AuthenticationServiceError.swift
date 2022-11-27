enum AuthenticationServiceError: Error, Equatable {
    case googleSignInFailure(String)
    case googleSignOutFailure(String)
    case noAuthenticationToken
    case noUserFound
    case missingFirebaseClientId
    case userCanceledSignInFlow
}
