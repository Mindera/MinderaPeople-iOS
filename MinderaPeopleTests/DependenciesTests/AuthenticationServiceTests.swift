@testable import MinderaPeople
import XCTest

final class AuthenticationServiceTests: XCTestCase {
    
    func testAuthenticationServiceUserSuccessfull() async {
        
        let mockedSignInService = GIDSignInMock()
        let currentUser = User.stub()
        let mockedFirebaseService = FirebaseAuthMock(currentUser: currentUser)
        
        let authenticationService = AuthenticationService(signInService: mockedSignInService,
                                                          firebaseService: mockedFirebaseService)
        
        let user = await authenticationService.user()
        
        XCTAssertEqual(currentUser, user)
    }
    
    func testAuthenticationServiceUserFailure() async {
        
        let mockedSignInService = GIDSignInMock()
        let mockedFirebaseService = FirebaseAuthMock(currentUser: nil)
        
        let authenticationService = AuthenticationService(signInService: mockedSignInService,
                                                          firebaseService: mockedFirebaseService)
        
        let user = await authenticationService.user()
        
        XCTAssertNil(user)
    }
    
    func testAuthenticationServiceSignInFailure() async {
        
        let mockedSignInService = GIDSignInMock()
        let mockedFirebaseService = FirebaseAuthMock(currentUser: nil)
        
        mockedSignInService.hasPreviousSignInResponse = false
        
        mockedSignInService.userResponse = nil
        mockedSignInService.errorResponse = AuthenticationServiceError.noUserFound
        
        let authenticationService = AuthenticationService(signInService: mockedSignInService,
                                                          firebaseService: mockedFirebaseService)
    
        do {
            let _ = try await authenticationService.signIn()
        } catch {
            XCTAssertNotNil(error)
            XCTAssert(error is AuthenticationServiceError)
        }
    }
    
//    func testAuthenticationServiceSignInSuccessfull() async {
//        
//        let mockedSignInService = GIDSignInMock()
//        let mockedFirebaseService = FirebaseAuthMock(currentUser: nil)
//        
//        mockedSignInService.hasPreviousSignInResponse = false
//        
//        mockedSignInService.errorResponse = nil
//        
//        let authenticationService = AuthenticationService(signInService: mockedSignInService,
//                                                          firebaseService: mockedFirebaseService)
//
//        do {
//            let _ = try await authenticationService.signIn()
//        } catch {
//            XCTAssertNotNil(error)
//            XCTAssert(error is AuthenticationServiceError)
//        }
//    }
    
}
