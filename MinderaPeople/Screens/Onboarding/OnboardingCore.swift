import ComposableArchitecture
import SwiftUI

struct Onboarding: ReducerProtocol {
    struct State: Equatable {
        var appState: AppState?
    }

    enum AppState: Equatable {
        case home
        case login
    }

    enum Action: Equatable {
        case onAppear
        case userResponse(TaskResult<User>)
    }
    
    @Dependency(\.minderaPeopleService) var minderaPeopleService
    @Dependency(\.keychainService) var keychainService

    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .onAppear:
            return .task {
                await .userResponse(
                    TaskResult {
                        try await minderaPeopleService.user(keychainService.load(.tokenKey))
                    }
                )
            }
            .delay(for: .seconds(1.5), scheduler: RunLoop.main)
            .eraseToEffect()

        case .userResponse(.failure):
            state.appState = .login
            
        case .userResponse(.success):
            state.appState = .home
        }
        return .none
    }
}
