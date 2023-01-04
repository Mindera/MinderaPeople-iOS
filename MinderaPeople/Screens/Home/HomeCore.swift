import ComposableArchitecture
import SwiftUI

struct Home: ReducerProtocol {
    struct State: Equatable {
        var alert: AlertState<Action>?
        var selectedTab: Tab = .dashboard
    }
    
    enum Tab {
        case dashboard
        case calendar
        case myProfile
    }
    
    enum Action: Equatable {
        case logOutButtonTapped
        case alertDismissTapped
        case tabButtonPressed(Tab)
    }
    
    @Dependency(\.keyChainService) var keyChainService
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logOutButtonTapped:
                keyChainService.remove(.tokenKey)
                
            case .alertDismissTapped:
                state.alert = nil
                
            case let .tabButtonPressed(tab):
                state.selectedTab = tab
            }
            
            return .none
        }
    }
}
