enum AuthenticationServiceError: Error, Equatable {
    case googleSignInFailure(String)
    case googleSignOutFailure(String)
    case noAuthenticationToken
    case noUserFound
    case missingFirebaseClientId
    case userCanceledSignInFlow
}

extension AuthenticationServiceError {
    static func authError(from error: Error) -> String? {
        guard let authError = error as? Self else { return nil }
        switch authError {
        case let .googleSignInFailure(errorText), let .googleSignOutFailure(errorText):
            return errorText
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
