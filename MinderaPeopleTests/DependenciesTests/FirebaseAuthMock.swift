@testable import MinderaPeople
import Firebase

struct MockFirebaseAuthDataResult: FirebaseAuthDataResultType {
    var user: Firebase.User
}

final class FirebaseAuthMock: FirebaseAuthProtocol {
    
    var userResponse: MockFirebaseAuthDataResult?
    var errorResponse: Error? = nil
    
    var currentUser: FirebaseUserType?
    
    init(currentUser: FirebaseUserType?) {
        self.currentUser = currentUser
    }
    
    func signIn(with: AuthCredential, completion: FirebaseAuthDataResultTypeCallback?) {
        completion?(userResponse, errorResponse)
    }
    
    func signOut() throws {
        print("fd")
    }
    

}



