import ComposableArchitecture
import Firebase
import GoogleSignIn
import MinderaDesignSystem
import SwiftUI

struct LoginFeature: ReducerProtocol {
    struct State: Equatable {
        var signInState: SignInState = .unauthorized
        var alert: AlertState<Action>?
        var isLoading = false
    }

    enum SignInState: Equatable {
        case authorized(User)
        case unauthorized
    }

    enum Action: Equatable {
        case logInButtonTapped
        case signInResponse(TaskResult<User>)
        case alertDismissTapped
    }

    @Dependency(\.authenticationService) var authenticationService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logInButtonTapped:
                state.isLoading = true
                return .task {
                    await .signInResponse(
                        TaskResult {
                            try await authenticationService.signIn()
                        }
                    )
                }
                
            case let .signInResponse(.failure(error)):
                state.isLoading = false
                guard let errorText = AuthenticationServiceError.authError(from: error) else { return .none }
                state.alert = AlertState.configure(message: errorText,
                                                   defaultAction: .logInButtonTapped,
                                                   cancelAction: .alertDismissTapped)

            case let .signInResponse(.success(user)):
                state.signInState = .authorized(user)

            case .alertDismissTapped:
                state.alert = nil
            }
            return .none
        }
    }
}

struct LoginView: View {
    let store: StoreOf<LoginFeature>
    @ObservedObject var viewStore: ViewStoreOf<LoginFeature>

    init(store: StoreOf<LoginFeature>) {
        self.store = store
        viewStore = .init(store)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewStore.isLoading {
                    LoaderView()
                } else {
                    Spacer()
                    Image("minderaLogo")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    MinderaButton(.title("Login with Google Account")) {
                        viewStore.send(.logInButtonTapped)
                    }
                    .contentMode(.fill)
                    .padding(.horizontal, 40)
                    .alert(
                        self.store.scope(state: \.alert),
                        dismiss: .alertDismissTapped
                    )
                }
            }
            .padding()
            .navigationBarBackButtonHidden()
            .navigationDestination(
                isPresented:
                        .init(
                            get: {
                                switch viewStore.signInState {
                                case .unauthorized:
                                    return false
                                case .authorized:
                                    return true
                                }
                            },
                            set: { _ in }
                        )
            ) {
                HomeView(store: .init(initialState: .init(), reducer: HomeFeature()))
            }
        }
    }
}

extension LoginFeature.State {
    static func mock(signInState: LoginFeature.SignInState = .unauthorized) -> Self {
        .init(signInState: signInState)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(store: .init(initialState: .mock(), reducer: LoginFeature()))
    }
}
