import ComposableArchitecture
import SwiftUI

struct Login: ReducerProtocol {
    struct State: Equatable {
        var isLoading = false
        var alert: AlertState<Action>?
        var isShowingWebView = false
        var userApiUrl = URL(string: "https://people.mindera.com/auth/google?mobile=ios")
    }

    enum Action: Equatable {
        case logInButtonTapped
        case userResponse(TaskResult<User>)
        case webViewDismissed
        case tokenResponse(String)
        case alertDismissTapped
    }

    @Dependency(\.minderaPeopleService) var minderaPeopleService
    @Dependency(\.keychainService) var keychainService

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
