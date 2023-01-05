import ComposableArchitecture

struct Root: ReducerProtocol {
    enum State: Equatable {
        case onboarding(Onboarding.State)
        case login(Login.State)
        case home(Home.State)

        init() {
            self = .home(.init())
        }
    }

    enum Action: Equatable {
        case onboarding(Onboarding.Action)
        case login(Login.Action)
        case home(Home.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .login(.userResponse(.success)),
                 .onboarding(.userResponse(.success)):
                state = .home(Home.State())
                return .none

            case .home(.logOutButtonTapped),
                 .onboarding(.userResponse(.failure)):
                state = .login(Login.State())
                return .none

            case .home,
                 .login,
                 .onboarding:
                return .none
            }
        }
        .ifCaseLet(/State.login, action: /Action.login) {
            Login()
        }
        .ifCaseLet(/State.home, action: /Action.home) {
            Home()
        }
        .ifCaseLet(/State.onboarding, action: /Action.onboarding) {
            Onboarding()
        }
    }
}
