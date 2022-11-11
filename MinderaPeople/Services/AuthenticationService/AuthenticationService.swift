import Dependencies
import Firebase
import GoogleSignIn

class AuthenticationService {
    func signIn() async throws -> User {
        // TODO: google and firebase instance should be injected in other to test this service
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            let user = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDGoogleUser?, Error>) in
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let error = error {
                        continuation.resume(throwing: AuthenticationServiceError.googleSignInFailure(error.localizedDescription))
                    } else {
                        continuation.resume(returning: user)
                    }
                }
            }

            return try await authenticateUser(for: user)
        } else {
            guard
                let clientID = FirebaseApp.app()?.options.clientID,
                let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = await windowScene.windows.first?.rootViewController
            else {
                throw AuthenticationServiceError.missingFirebaseClientId
            }

            let configuration = GIDConfiguration(clientID: clientID)

            let user = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDGoogleUser?, Error>) in
                // TODO: this triggers a warning because we are using rootViewController from background thread. Check solution.
                GIDSignIn.sharedInstance.signIn(
                    with: configuration,
                    presenting: rootViewController
                ) { user, error in
                    if let error = error {
                        continuation.resume(throwing: AuthenticationServiceError.googleSignInFailure(error.localizedDescription))
                    } else {
                        continuation.resume(returning: user)
                    }
                }
            }

            return try await authenticateUser(for: user)
        }
    }

    private func authenticateUser(for user: GIDGoogleUser?) async throws -> User {
        guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
        else {
            throw AuthenticationServiceError.noAuthenticationToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: authentication.accessToken
        )

        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let user = result?.user else {
                    continuation.resume(throwing: AuthenticationServiceError.noUserFound)
                    return
                }
                continuation.resume(returning: user)
            }
        }
    }

    func signOut() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}

extension DependencyValues {
    var authenticationService: AuthenticationService {
        get { self[AuthenticationService.self] }
        set { self[AuthenticationService.self] = newValue }
    }
}

// TODO: we should add proper mocked values
extension AuthenticationService: TestDependencyKey {
    static var testValue = AuthenticationService()
}
