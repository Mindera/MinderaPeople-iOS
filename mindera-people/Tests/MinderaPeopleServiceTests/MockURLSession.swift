import Foundation
import MinderaPeopleService

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
            data = Bundle.module.dataFromResource("UserSuccess")
        case .userFailure:
            data = Bundle.module.dataFromResource("UserFailure")
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

extension Bundle {
    func dataFromResource(_ resource: String) -> Data {
        guard let mockURL = url(forResource: resource,
                                withExtension: "json"),
              let data = try? Data(contentsOf: mockURL) else {
                 fatalError("Failed to load \(resource) from bundle.")
        }
        return data
    }
}
