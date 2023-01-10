import ComposableArchitecture
import SwiftUI
import MinderaPeopleService
import KeychainService

public struct Onboarding: ReducerProtocol {
    public struct State: Equatable {
        public var appState: AppState?
        
        public init() {}
    }
    
    public enum AppState: Equatable {
        case home
        case login
    }
    
    public enum Action: Equatable {
        case onAppear
        case userResponse(TaskResult<User>)
    }
    
    @Dependency(\.minderaPeopleService) var minderaPeopleService
    @Dependency(\.keychainService) var keychainService
    
    public init() {}
    
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
