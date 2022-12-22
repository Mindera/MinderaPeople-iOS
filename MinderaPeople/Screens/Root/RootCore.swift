import ComposableArchitecture

struct Root: ReducerProtocol {
    enum State: Equatable {
        case login(Login.State)
        case home(Home.State)
        
        init() { self = .login(.init()) }
    }
    
    enum Action: Equatable {
        case login(Login.Action)
        case home(Home.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .login(.userResponse(.success)):
                state = .home(Home.State())
                return .none
                
            case .home(.logOutButtonTapped):
                state = .login(Login.State())
                return .none
                
            case .home, .login:
                return .none
            }
        }
        .ifCaseLet(/State.login, action: /Action.login) {
          Login()
        }
        .ifCaseLet(/State.home, action: /Action.home) {
          Home()
        }
    }
}
