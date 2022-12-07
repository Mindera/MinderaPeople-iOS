import ComposableArchitecture
import Firebase
import GoogleSignIn

extension AuthenticationServiceClient: DependencyKey {
    public static var liveValue: Self {
        let authenticationService = AuthenticationService()
        return Self(
            user: { await authenticationService.user() },
            signIn: { try await authenticationService.signIn() },
            signOut: { try await authenticationService.signOut() }
        )
    }
}

private struct AuthenticationService {
    let signInInstance = GIDSignIn.sharedInstance

    func user() async -> User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return .init(firebaseUser)
    }

    func signIn() async throws -> User {
        // TODO: google and firebase instance should be injected in other to test this service
        guard
            signInInstance.hasPreviousSignIn() else {
            guard
                let clientID = FirebaseApp.app()?.options.clientID,
                let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = await windowScene.windows.first?.rootViewController
            else {
                throw AuthenticationServiceError.missingFirebaseClientId
            }

            let configuration = GIDConfiguration(clientID: clientID)

            return try await authenticateUser(for: signInInstance.signInUser(configuration: configuration,
                                                                             rootViewController: rootViewController))
        }
        
        return try await authenticateUser(for: signInInstance.restorePreviousSignInUser())
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
                continuation.resume(returning: .init(user))
            }
        }
    }

    func signOut() async throws -> VoidEquatable {
        signInInstance.signOut()
        try Auth.auth().signOut()
        return .init()
    }
}

private extension User {
    init(_ data: Firebase.User) {
        uid = data.uid
        isAnonymous = data.isAnonymous
        phoneNumber = data.phoneNumber
        email = data.email
        displayName = data.displayName
        isEmailVerified = data.isEmailVerified
        photoURL = data.photoURL
        refreshToken = data.refreshToken
    }
}