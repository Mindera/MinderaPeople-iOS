import ComposableArchitecture
import SwiftUI

struct Login: ReducerProtocol {
    struct State: Equatable {
        var isLoading = false
        var alert: AlertState<Action>?
        var isShowingWebView = false
    }

    enum Action: Equatable {
        case logInButtonTapped
        case userResponse(TaskResult<User>)
        case webViewDismissed
        case tokenResponse(String)
        case alertDismissTapped
    }

    @Dependency(\.minderaPeopleService) var minderaPeopleService
    @Dependency(\.keyChainService) var keyChainService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logInButtonTapped:
                state.isShowingWebView = true
                state.isLoading = true

            case let .tokenResponse(token):
                keyChainService.update(token, .tokenKey)
                state.isShowingWebView = false
                return .task {
                    await .userResponse(
                        TaskResult {
                            try await minderaPeopleService.user(token)
                        }
                    )
                }

            case let .userResponse(.failure(error)):
                state.isLoading = false
                state.alert = AlertState.configure(message: error.localizedDescription,
                                                   defaultAction: .logInButtonTapped,
                                                   cancelAction: .alertDismissTapped)

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
}
