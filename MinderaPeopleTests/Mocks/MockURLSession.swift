import Foundation
@testable import MinderaPeople

class MockSessionDataTask: URLSessionDataTaskProtocol {
    func resume() {}
}

class MockURLSession: URLSessionProtocol {
    private var expectedDataTask = MockSessionDataTask()
    var expectedResponse: NetworkResponse = .userSuccess
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        var data: Data?
        var error: Error?
        
        switch expectedResponse {
        case .userSuccess:
            data = loadJsonDataFromFile(name: "UserSuccess")
        case .userFailure:
            data = loadJsonDataFromFile(name: "UserFailure")
        case .error:
            error = MinderaPeopleServiceError.networkError
        }
        
        completionHandler(data, nil, error)
        return expectedDataTask
    }
    
    enum NetworkResponse {
        case userSuccess
        case userFailure
        case error
    }
}
