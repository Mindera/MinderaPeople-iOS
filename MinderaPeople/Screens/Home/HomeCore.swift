import ComposableArchitecture
import SwiftUI

struct Home: ReducerProtocol {
    struct State: Equatable {
        var alert: AlertState<Action>?
    }
    
    enum Action: Equatable {
        case logOutButtonTapped
        case alertDismissTapped
    }
    
    @Dependency(\.keyChainService) var keyChainService
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
                switch action {
                case .logOutButtonTapped:
                    keyChainService.remove(.tokenKey)
                    
                case .alertDismissTapped:
                    state.alert = nil
                }

                return .none
            }
    }
}
