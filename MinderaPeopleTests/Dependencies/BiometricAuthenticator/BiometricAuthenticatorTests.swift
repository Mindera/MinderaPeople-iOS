import LocalAuthentication
import XCTest

@testable import MinderaPeople

final class BiometricAuthenticatorTests: XCTestCase {
    private let mockedContext = LAContextMock()
    private var userDefaultsClient = UserDefaultsClient.testValue
    private let currentDate = Date()
    
    func testAuthenticationSuccessful() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        userDefaultsClient.override(date: currentDate, forKey: UserDefaultsKeys.lastBiometricAuthenticationDateKey)
        let biometricAuthenticator = BiometricAuthenticator(authenticationContext: mockedContext,
                                                            userDefaults: userDefaultsClient,
                                                            referenceDate: currentDate.addingTimeInterval(205))
        await biometricAuthenticator.setAuthenticationTimeLimit(200)
        do {
            let successful = try await biometricAuthenticator.authenticate(force: false)
            XCTAssertTrue(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }
    
    func testSuccessfulAuthenticationWithinTimeLimit() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        userDefaultsClient.override(date: currentDate, forKey: UserDefaultsKeys.lastBiometricAuthenticationDateKey)
        let biometricAuthenticator = BiometricAuthenticator(authenticationContext: mockedContext,
                                                            userDefaults: userDefaultsClient,
                                                            referenceDate: currentDate.addingTimeInterval(150))
        await biometricAuthenticator.setAuthenticationTimeLimit(200)
        do {
            let successful = try await biometricAuthenticator.authenticate(force: false)
            XCTAssertTrue(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }

    
    func testBiometricAuthenticationNotEnabled() async {
        userDefaultsClient.override(bool: false, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        let biometricAuthenticator = BiometricAuthenticator(authenticationContext: mockedContext,
                                                            userDefaults: userDefaultsClient)
        do {
            let successful = try await biometricAuthenticator.authenticate(force: false)
            XCTAssertFalse(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }
    
    func testForcedAuthentication() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        let biometricAuthenticator = BiometricAuthenticator(authenticationContext: mockedContext,
                                                            userDefaults: userDefaultsClient)
        do {
            let successful = try await biometricAuthenticator.authenticate(force: true)
            XCTAssertTrue(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }
    
    func testBiometricNotEnrolled() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        mockedContext.canEvaluatePolicyResponse = false
        let biometricAuthenticator = BiometricAuthenticator(authenticationContext: mockedContext,
                                                            userDefaults: userDefaultsClient)
        do {
            let _ = try await biometricAuthenticator.authenticate(force: true)
        } catch {
            XCTAssertNotNil(error)
            XCTAssert(error is BiometricAuthenticatorError)
        }
    }
    
    func testBiometricAuthenticationFailedFaceRecognition() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        mockedContext.evaluatePolicyResponse = false
        let biometricAuthenticator = BiometricAuthenticator(authenticationContext: mockedContext,
                                                            userDefaults: userDefaultsClient)
        do {
            let successful = try await biometricAuthenticator.authenticate(force: true)
            XCTAssertFalse(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }
}
