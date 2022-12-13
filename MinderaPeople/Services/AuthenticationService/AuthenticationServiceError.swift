enum AuthenticationServiceError: Error, Equatable {
    static func == (lhs: AuthenticationServiceError, rhs: AuthenticationServiceError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
    
    case googleSignInFailure(Error)
    case googleSignOutFailure(Error)
    case noAuthenticationToken
    case noUserFound
    case missingFirebaseClientId
    case userCanceledSignInFlow
}

extension AuthenticationServiceError {
    static func authError(from error: Error) -> String? {
        guard let authError = error as? Self else { return nil }
        switch authError {
        case let .googleSignInFailure(error), let .googleSignOutFailure(error):
            return error.localizedDescription
        case .noAuthenticationToken:
            return "noAuthenticationToken"
        case .noUserFound:
            return "noUserFound"
        case .missingFirebaseClientId:
            return "missingFirebaseClientId"
        case .userCanceledSignInFlow:
            return nil
        }
    }
}
