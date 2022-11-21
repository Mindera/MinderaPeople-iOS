import ComposableArchitecture
import Firebase
import GoogleSignIn
import MinderaPeople_iOS_DesignSystem
import SwiftUI

struct LoginFeature: ReducerProtocol {
    struct State: Equatable {
        var signInState: SignInState = .unauthorized
        var alert: AlertState<Action>?
    }

    enum SignInState: Equatable {
        case authorized(User)
        case unauthorized
    }

    enum Action: Equatable {
        case onAppear
        case userPersistenceResponse(TaskResult<User>)
        case logInButtonTapped
        case signInResponse(TaskResult<User>)
        case homePageDismiss
        case alertDismissTapped
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

            case .userPersistenceResponse(.failure):
                return .none

            case let .userPersistenceResponse(.success(user)):
                state.signInState = .authorized(user)
                return .none

            case .logInButtonTapped:
                return .task {
                    await .signInResponse(
                        TaskResult {
                            try await authenticationService.signIn()
                        }
                    )
                }

            case let .signInResponse(.failure(error)):
                guard let errorText = authError(from: error) else { return .none }
                state.alert = AlertState(
                    title: TextState("Something went wrong"),
                    message: TextState(errorText),
                    primaryButton: .default(TextState("Retry"), action: .send(.logInButtonTapped)),
                    secondaryButton: .cancel(TextState("Ok"), action: .send(.alertDismissTapped))
                )
                return .none

            case let .signInResponse(.success(user)):
                state.signInState = .authorized(user)
                return .none

            case .homePageDismiss:
                state.signInState = .unauthorized
                return .none

            case .alertDismissTapped:
                state.alert = nil
                return .none
            }
        }
    }

    private func authError(from error: Error) -> String? {
        guard let authError = error as? AuthenticationServiceError else { return nil }
        switch authError {
        case let .googleSignInFailure(error):
            return error
        case .noAuthenticationToken:
            return "noAuthenticationToken"
        case .noUserFound:
            return "noUserFound"
        case .missingFirebaseClientId:
            return "missingFirebaseClientId"
        case let .googleSignOutFailure(error):
            return error
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
            .padding()
            .navigationBarBackButtonHidden()
            .navigationDestination(
                isPresented: viewStore
                    .binding(
                        get: { state in
                            switch state.signInState {
                            case .unauthorized:
                                return false
                            case .authorized:
                                return true
                            }
                        },
                        send: .homePageDismiss
                    )
            ) {
                HomeView(store: .init(initialState: .init(), reducer: HomeFeature()))
            }
            .onAppear {
                viewStore.send(.onAppear)
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
