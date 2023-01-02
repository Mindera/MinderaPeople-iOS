import ComposableArchitecture
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
    }

    @Dependency(\.authenticationService) var authenticationService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task {
                    if let user = await authenticationService.user() {
                        return .userPersistenceResponse(.success(user))
                    }
                    return .userPersistenceResponse(.failure(AuthenticationServiceError.noUserFound))
                }
                .delay(for: .seconds(1.5), scheduler: RunLoop.main)
                .eraseToEffect()

            case .userPersistenceResponse(.failure):
                state.signInState = .unauthorized

            case let .userPersistenceResponse(.success(user)):
                state.signInState = .authorized(user)
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
                Spacer()
                Image("minderaLogo")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)

                Spacer()
            }
            .navigationDestination(
                isPresented:
                        .init(
                            get: { viewStore.signInState?.isAuthorized ?? false },
                            set: { _ in }
                        )
            ) {
                HomeView(store: .init(initialState: .init(), reducer: HomeFeature()))
            }
            .navigationDestination(
                isPresented:
                        .init(
                            get: { viewStore.signInState?.isAuthorized == false },
                            set: { _ in }
                        )
            ) {
                LoginView(store: .init(initialState: .init(), reducer: LoginFeature()))
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
