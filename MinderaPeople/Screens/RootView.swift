import ComposableArchitecture
import MinderaPeople_iOS_DesignSystem
import SwiftUI

struct RootFeature: ReducerProtocol {
    struct State: Equatable {
        var signInState: SignInState?
    }

    enum SignInState: Equatable {
        case authorized(User)
        case unauthorized
        
        var isAuthorized: Bool {
            switch self {
            case .authorized:
                return true
            case .unauthorized:
                return false
            }
        }
    }

    enum Action: Equatable {
        case onAppear
        case userPersistenceResponse(TaskResult<User>)
        case signStateUpdated(SignInState)
    }

    @Dependency(\.minderaPeopleService) var minderaPeopleService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task {
                    await .userPersistenceResponse(
                        TaskResult {
                            try await minderaPeopleService.user()
                        }
                    )
                }
                .delay(for: .seconds(1.5), scheduler: RunLoop.main)
                .eraseToEffect()

            case .userPersistenceResponse(.failure):
                state.signInState = .unauthorized

            case let .userPersistenceResponse(.success(user)):
                state.signInState = .authorized(user)
            case let .signStateUpdated(newState):
                state.signInState = newState
            }
            return .none
        }
    }
}

struct RootView: View {
    let store: StoreOf<RootFeature>
    @ObservedObject var viewStore: ViewStoreOf<RootFeature>

    init(store: StoreOf<RootFeature>) {
        self.store = store
        viewStore = .init(store)
    }

    var body: some View {
        NavigationStack {
            VStack {
                switch viewStore.signInState {
                case .none:
                    Spacer()
                    Image("minderaLogo")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)

                    Spacer()
                case .authorized:
                    HomeView(store: .init(initialState: .init(), reducer: HomeFeature(loginStateChanged: { newState in
                        viewStore.send(.signStateUpdated(newState))
                    })))
                case .unauthorized:
                    LoginView(store: .init(initialState: .init(), reducer: LoginFeature(loginStateChanged: { newState in
                        viewStore.send(.signStateUpdated(newState))
                    })))
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

extension RootFeature.State {
    static func mock(signInState: RootFeature.SignInState? = nil) -> Self {
        .init(signInState: signInState)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: .init(
                initialState: .mock(),
                reducer: RootFeature()
            )
        )
    }
}
