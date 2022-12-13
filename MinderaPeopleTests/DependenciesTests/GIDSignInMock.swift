@testable import MinderaPeople
import GoogleSignIn

final class GIDSignInMock: GIDSignInProtocol {
    
    var hasPreviousSignInResponse = true
    var userResponse: GIDGoogleUser? = GIDGoogleUser()
    var errorResponse: Error? = nil
    
    func hasPreviousSignIn() -> Bool {
        return hasPreviousSignInResponse
    }
    
    func signIn(with: GIDConfiguration, presenting: UIViewController, callback: GIDSignInCallback?) {
        callback?(userResponse, errorResponse)
    }
    
    func restorePreviousSignIn(callback: GIDSignInCallback?) {
        callback?(userResponse, errorResponse)
    }
    
    func signOut() {
        hasPreviousSignInResponse = false
    }
}
