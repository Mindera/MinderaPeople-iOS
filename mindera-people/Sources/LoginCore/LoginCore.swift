import ComposableArchitecture
import SwiftUI
import MinderaPeopleService
import KeychainService

public struct Login: ReducerProtocol {
    public struct State: Equatable {
        public var isLoading = false
        public var alert: AlertState<Action>?
        public var isShowingWebView = false
        public var userApiUrl = URL(string: "https://people.mindera.com/auth/google?mobile=ios")
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case logInButtonTapped
        case userResponse(TaskResult<User>)
        case webViewDismissed
        case tokenResponse(String)
        case alertDismissTapped
    }
    
    @Dependency(\.minderaPeopleService) var minderaPeopleService
    @Dependency(\.keychainService) var keychainService
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .logInButtonTapped:
            state.isShowingWebView = true
            state.isLoading = true
            
        case let .tokenResponse(token):
            state.isShowingWebView = false
            
            return .merge(
                .fireAndForget {
                    keychainService.update(token, .tokenKey)
                },
                .task {
                    await .userResponse(
                        TaskResult {
                            try await minderaPeopleService.user(token)
                        }
                    )
                }
            )
            
        case let .userResponse(.failure(error)):
            state.isLoading = false
            state.alert = AlertState.configure(
                message: error.localizedDescription,
                defaultAction: .logInButtonTapped,
                cancelAction: .alertDismissTapped
            )
            
        case .userResponse(.success):
            state.isLoading = false
            
        case .webViewDismissed:
            state.isShowingWebView = false
            state.isLoading = false
            
        case .alertDismissTapped:
            state.alert = nil
        }
        return .none
    }
}
