import LocalAuthentication
import XCTest
import UserDefaultsClient

@testable import BiometricAuthenticatorClient

final class BiometricAuthenticatorTests: XCTestCase {
    private var mockedContext: LAContextMock!
    private var userDefaultsClient: UserDefaultsClient!
    private var currentDate: Date!
    
    private var sut: BiometricAuthenticator!
    
    override func setUp() {
        super.setUp()
        mockedContext = .init()
        userDefaultsClient = .testValue
        currentDate = Date()
    }
    
    override func tearDown() {
        sut = nil
        currentDate = nil
        userDefaultsClient = nil
        mockedContext = nil
        super.tearDown()
    }
    
    func testAuthenticationSuccessful() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        userDefaultsClient.override(date: currentDate, forKey: UserDefaultsKeys.lastBiometricAuthenticationDateKey)
        sut = BiometricAuthenticator(
            authenticationContext: mockedContext,
            userDefaults: userDefaultsClient,
            referenceDate: currentDate.addingTimeInterval(205)
        )
        
        await sut.setAuthenticationTimeLimit(200)
        do {
            let successful = try await sut.authenticate(force: false)
            XCTAssertEqual(mockedContext.canEvaluatePolicyCalledCount, 1)
            XCTAssertEqual(mockedContext.evaluatePolicyCalledCount, 1)
            XCTAssertEqual(mockedContext.lastCanEvaluatePolicyLAPolicy, .deviceOwnerAuthenticationWithBiometrics)
            XCTAssertEqual(mockedContext.lastEvaluatePolicyLAPolicy, .deviceOwnerAuthenticationWithBiometrics)
            XCTAssertTrue(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }
    
    func testSuccessfulAuthenticationWithinTimeLimit() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        userDefaultsClient.override(date: currentDate, forKey: UserDefaultsKeys.lastBiometricAuthenticationDateKey)
        sut = BiometricAuthenticator(
            authenticationContext: mockedContext,
            userDefaults: userDefaultsClient,
            referenceDate: currentDate.addingTimeInterval(150)
        )
        await sut.setAuthenticationTimeLimit(200)
        do {
            let successful = try await sut.authenticate(force: false)
            XCTAssertTrue(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }

    
    func testBiometricAuthenticationNotEnabled() async {
        userDefaultsClient.override(bool: false, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        sut = BiometricAuthenticator(
            authenticationContext: mockedContext,
            userDefaults: userDefaultsClient
        )
        do {
            let successful = try await sut.authenticate(force: false)
            XCTAssertEqual(mockedContext.canEvaluatePolicyCalledCount, 0)
            XCTAssertEqual(mockedContext.evaluatePolicyCalledCount, 0)
            XCTAssertFalse(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }
    
    func testForcedAuthentication() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        sut = BiometricAuthenticator(
            authenticationContext: mockedContext,
            userDefaults: userDefaultsClient
        )
        do {
            let successful = try await sut.authenticate(force: true)
            XCTAssertTrue(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }
    
    func testBiometricNotEnrolled() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        mockedContext.canEvaluatePolicyResponse = false
        sut = BiometricAuthenticator(
            authenticationContext: mockedContext,
            userDefaults: userDefaultsClient
        )
        do {
            let _ = try await sut.authenticate(force: true)
        } catch {
            XCTAssertEqual(mockedContext.canEvaluatePolicyCalledCount, 1)
            XCTAssertEqual(mockedContext.evaluatePolicyCalledCount, 0)
            XCTAssertNotNil(error)
            XCTAssert(error is BiometricAuthenticatorError)
        }
    }
    
    func testBiometricAuthenticationFailedFaceRecognition() async {
        userDefaultsClient.override(bool: true, forKey: UserDefaultsKeys.biometricAuthenticationEnabled)
        mockedContext.evaluatePolicyResponse = false
        sut = BiometricAuthenticator(
            authenticationContext: mockedContext,
            userDefaults: userDefaultsClient
        )
        do {
            let successful = try await sut.authenticate(force: true)
            XCTAssertFalse(successful)
        } catch {
            XCTFail("No errors should be received")
        }
    }
}
