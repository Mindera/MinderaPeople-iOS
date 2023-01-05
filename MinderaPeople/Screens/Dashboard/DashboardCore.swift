import ComposableArchitecture
import SwiftUI

struct Dashboard: ReducerProtocol {
    struct State: Equatable {
        var greetingMessage: String = "Hello"
        var hasNotifications: Bool = false // TODO: Add proper logic when notifications logic is integrated
        var notificationsIconName: String { hasNotifications ? "notifications_bell" : "bell"}
    }

    enum Action: Equatable {
        case onAppear
        case userNameFetched(TaskResult<String>)
        case notificationsResponse(TaskResult<Bool>)
        case none
    }

    @Dependency(\.minderaPeopleService) var minderaPeopleService
    @Dependency(\.keyChainService) var keyChainService
    @Dependency(\.logger) var logger
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task {
                    await .userNameFetched(
                        TaskResult {
                            try await minderaPeopleService.user(keyChainService.load(.tokenKey)).name
                        }
                    )
                }
            case .userNameFetched(.success(let userName)):
                state.greetingMessage = "Hello, \(userName)"
                return .none
            case .userNameFetched(.failure(let error)):
                logger.logError(error.localizedDescription)
                return .none
            case .notificationsResponse(.success(let hasNotifications)):
                state.hasNotifications = hasNotifications
                return .none
            case .notificationsResponse(.failure(let error)):
                logger.logError(error.localizedDescription)
                return .none
            case .none:
                return .none
            }
        }
    }
}
