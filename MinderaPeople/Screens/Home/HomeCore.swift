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
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
                switch action {
                case .logOutButtonTapped:
                    UserDefaults.standard.removeObject(forKey: "Token")
//                    loginStateChanged(.unauthorized)
                    
                case .alertDismissTapped:
                    state.alert = nil
                }

                return .none
            }
    }
}
