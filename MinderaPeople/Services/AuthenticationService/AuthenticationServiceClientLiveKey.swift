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

final class Authentication: FirebaseAuthProtocol {
    static let sharedInstance = Authentication()
    private let auth = Auth.auth()
    var currentUser: FirebaseUserType? {
        return auth.currentUser
    }
    
    func signIn(with: AuthCredential, completion: FirebaseAuthDataResultTypeCallback?) {
        let completion = completion as ((AuthDataResult?, Error?) -> Void)?
        auth.signIn(with: with, completion: completion)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}

protocol FirebaseAuthDataResultType {
    var user: Firebase.User { get }
}

extension AuthDataResult: FirebaseAuthDataResultType {}

typealias FirebaseAuthDataResultTypeCallback = (FirebaseAuthDataResultType?, Error?) -> Void

protocol GIDSignInProtocol {
    func hasPreviousSignIn() -> Bool
    func signIn(with: GIDConfiguration,
                presenting: UIViewController,
                callback: GIDSignInCallback?)
    func restorePreviousSignIn(callback: GIDSignInCallback?)
    func signOut()
}

protocol FirebaseAuthProtocol {
    var currentUser: FirebaseUserType? { get }
    
    func signIn(with: AuthCredential, completion: FirebaseAuthDataResultTypeCallback?)
    func signOut() throws
}

extension GIDSignIn: GIDSignInProtocol {}

public struct AuthenticationService {
    private let signInService: GIDSignInProtocol
    private let firebaseService: FirebaseAuthProtocol
    
    init(signInService: GIDSignInProtocol = GIDSignIn.sharedInstance,
         firebaseService: FirebaseAuthProtocol = Authentication.sharedInstance) {
        self.signInService = signInService
        self.firebaseService = firebaseService
    }

    func user() async -> User? {
        guard let firebaseUser = firebaseService.currentUser else { return nil }
        return .init(firebaseUser)
    }

    func signIn() async throws -> User {
        guard
            signInService.hasPreviousSignIn() else {
            guard
                let clientID = FirebaseApp.app()?.options.clientID,
                let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = await windowScene.windows.first?.rootViewController
            else {
                throw AuthenticationServiceError.missingFirebaseClientId
            }

            let configuration = GIDConfiguration(clientID: clientID)

            return try await authenticateUser(for: signInUser(configuration: configuration,
                                                              rootViewController: rootViewController))
        }
        
        return try await authenticateUser(for: restorePreviousSignInUser())
    }
    
    private func signInUser(configuration: GIDConfiguration,
                            rootViewController: UIViewController) async throws -> GIDGoogleUser? {
        let user: GIDGoogleUser? = try await withCheckedThrowingContinuation { continuation in
            // TODO: this triggers a warning because we are using rootViewController from background thread. Check solution.
            signInService.signIn(
                with: configuration,
                presenting: rootViewController
            ) { user, error in
                if let error = error {
                    guard (error as NSError).code == GIDSignInError.Code.canceled.rawValue else {
                        continuation.resume(throwing: AuthenticationServiceError.googleSignInFailure(error))
                        return
                    }
                    continuation.resume(throwing: AuthenticationServiceError.userCanceledSignInFlow)
                } else {
                    continuation.resume(returning: user)
                }
            }
        }
        
        return user
    }
    
    private func restorePreviousSignInUser() async throws -> GIDGoogleUser? {
        let user: GIDGoogleUser? = try await withCheckedThrowingContinuation { continuation in
            signInService.restorePreviousSignIn { user, error in
                if let error = error {
                    continuation.resume(throwing: AuthenticationServiceError.googleSignInFailure(error))
                } else {
                    continuation.resume(returning: user)
                }
            }
        }
        
        return user
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
            firebaseService.signIn(with: credential) { result, error in
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
        signInService.signOut()
        try firebaseService.signOut()
        return .init()
    }
}

private extension User {
    init(_ data: FirebaseUserType) {
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

protocol FirebaseUserType {
    var uid: String { get }
    var isAnonymous: Bool { get }
    var phoneNumber: String? { get }
    var email: String? { get }
    var displayName: String? { get }
    var isEmailVerified: Bool { get }
    var photoURL: URL? { get }
    var refreshToken: String? { get }
}

extension Firebase.User: FirebaseUserType {}
extension User: FirebaseUserType {}
