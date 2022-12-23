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

public struct MinderaPeopleService {

    func user(token: String?) async throws -> User {
        
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
                      request: request) { result in
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
    private func getResult<T: Decodable>(of type: T.Type, request: URLRequest, completion: @escaping ParameterClosure<Result<T, MinderaPeopleServiceError>>) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil, data != nil, let data = data {  // handle error
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(MinderaPeopleServiceError.parseError))
                }
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

