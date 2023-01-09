import ComposableArchitecture
import KeychainService
import SwiftUI

public struct Home: ReducerProtocol {
    public struct State: Equatable {
        public var alert: AlertState<Action>?
        public var selectedTab: Tab = .dashboard
        
        public init() {}
    }
    
    public enum Tab {
        case dashboard
        case calendar
        case myProfile
    }
    
    public enum Action: Equatable {
        case logOutButtonTapped
        case alertDismissTapped
        case tabButtonPressed(Tab)
    }
    
    @Dependency(\.keychainService) var keychainService
    
    public init() {}
    
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
