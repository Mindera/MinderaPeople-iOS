import GoogleSignIn

protocol GIDSignInProtocol {
    func hasPreviousSignIn() -> Bool
    func signIn(with: GIDConfiguration,
                presenting: UIViewController,
                callback: GIDSignInCallback?)
    func restorePreviousSignIn(callback: GIDSignInCallback?)
    func signOut()
}

extension GIDSignIn: GIDSignInProtocol {}
