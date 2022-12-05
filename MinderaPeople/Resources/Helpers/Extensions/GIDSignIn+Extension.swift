import GoogleSignIn

extension GIDSignIn {
    func restorePreviousSignInUser() async throws -> GIDGoogleUser? {
        let user: GIDGoogleUser? = try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    continuation.resume(throwing: AuthenticationServiceError.googleSignInFailure(error))
                } else {
                    continuation.resume(returning: user)
                }
            }
        }
        
        return user
    }
    
    func signInUser(configuration: GIDConfiguration, rootViewController: UIViewController) async throws -> GIDGoogleUser? {
        let user: GIDGoogleUser? = try await withCheckedThrowingContinuation { continuation in
            // TODO: this triggers a warning because we are using rootViewController from background thread. Check solution.
            GIDSignIn.sharedInstance.signIn(
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
}
