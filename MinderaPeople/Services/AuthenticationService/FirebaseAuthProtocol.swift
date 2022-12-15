import Firebase

typealias FirebaseAuthDataResultTypeCallback = (FirebaseAuthDataResultType?, Error?) -> Void

protocol FirebaseAuthProtocol {
    var currentUser: FirebaseUserType? { get }
    
    func signIn(with: AuthCredential, completion: FirebaseAuthDataResultTypeCallback?)
    func signOut() throws
}

protocol FirebaseAuthDataResultType {
    var user: Firebase.User { get }
}

extension AuthDataResult: FirebaseAuthDataResultType {}
