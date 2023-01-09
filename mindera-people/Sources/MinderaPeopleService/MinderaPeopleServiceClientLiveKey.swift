import ComposableArchitecture
import Foundation

extension MinderaPeopleServiceClient: DependencyKey {
    public static var liveValue: Self {
        let minderaPeopleService = MinderaPeopleService()
        return Self(
            user: { token in try await minderaPeopleService.user(token: token) }
        )
    }
}

public protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    public func dataTask(with request: URLRequest,
                         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler)
    }
}

public struct MinderaPeopleService {
    
    private let session: URLSessionProtocol
    
    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    public func user(token: String?) async throws -> User {
        
        guard let token = token else {
            throw MinderaPeopleServiceError.noToken
        }
        
        guard let url = URL(string: Api.getUser.rawValue) else {
            throw MinderaPeopleServiceError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("bearer \(token)", forHTTPHeaderField: "authorization")
        
        let user: User = try await withCheckedThrowingContinuation { continuation in
            getResult(of: UserResponse.self,
                      request: request,
                      session: session) { result in
                switch result {
                case let .success(user):
                    continuation.resume(returning: User(id: user.person.id,
                                                        name: user.person.name,
                                                        photo: user.person.photo,
                                                        email: user.person.email))
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return user
    }
}

extension MinderaPeopleService {
    private func getResult<T: Decodable>(of type: T.Type,
                                         request: URLRequest,
                                         session: URLSessionProtocol,
                                         completion: @escaping ParameterClosure<Result<T, MinderaPeopleServiceError>>) {
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(MinderaPeopleServiceError.networkError))
                return
            }
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(MinderaPeopleServiceError.parseError))
            }
        }.resume()
    }
}

extension MinderaPeopleService {
    enum Api: String {
        case getUser = "https://people.mindera.com/api/user"
    }
}

typealias ParameterClosure<T> = (T) -> Void

