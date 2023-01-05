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
    
    @Dependency(\.keychainService) var keychainService
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .logOutButtonTapped:
            keychainService.remove(.tokenKey)
            
        case .alertDismissTapped:
            state.alert = nil
            
        case let .tabButtonPressed(tab):
            state.selectedTab = tab
        }

        return .none
    }
}
