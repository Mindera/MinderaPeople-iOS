@testable import MinderaPeople
import XCTest

final class MinderaPeopleServiceTests: XCTestCase {
    private var mockedURLSession: MockURLSession!
    private var service: MinderaPeopleService!
    
    override func setUp() {
        super.setUp()
        mockedURLSession = .init()
    }

    override func tearDown() {
        mockedURLSession = nil
        service = nil
        super.tearDown()
    }
    
    func testNoTokenPassed() async {
        mockedURLSession.expectedResponse = .userSuccess
        service = MinderaPeopleService(session: mockedURLSession)
        
        do {
            _ = try await service.user(token: nil)
        } catch {
            XCTAssertEqual(error as? MinderaPeopleServiceError, MinderaPeopleServiceError.noToken)
        }
    }
    
    func testUserSuccessResponse() async {
        mockedURLSession.expectedResponse = .userSuccess
        service = MinderaPeopleService(session: mockedURLSession)
        
        do {
            let user = try await service.user(token: "12345")
            XCTAssertEqual(user, .stub())
        } catch {
            XCTFail("No errors should be received")
        }
    }
    
    func testUserFailureResponse() async {
        mockedURLSession.expectedResponse = .userFailure
        service = MinderaPeopleService(session: mockedURLSession)
    
        do {
            _ = try await service.user(token: "12345")
        } catch {
            XCTAssertEqual(error as? MinderaPeopleServiceError, MinderaPeopleServiceError.parseError)
        }
    }
    
    func testNetworkErrorResponse() async {
        mockedURLSession.expectedResponse = .error
        service = MinderaPeopleService(session: mockedURLSession)
    
        do {
            _ = try await service.user(token: "12345")
        } catch {
            XCTAssertEqual(error as? MinderaPeopleServiceError, MinderaPeopleServiceError.networkError)
        }
    }
}

extension MockURLSession {
    func loadJsonDataFromFile(name: String, withExtension: String = "json") -> Data? {
        let bundle = Bundle(for: type(of: self))
        if let fileUrl = bundle.url(forResource: name, withExtension: withExtension) {
            return try? Data(contentsOf: fileUrl)
        } else {
            return nil
        }
    }
}

