import ComposableArchitecture
import WebKit
import MinderaPeople_iOS_DesignSystem
import SwiftUI

struct LoginFeature: ReducerProtocol {
    struct State: Equatable {
        var signInState: SignInState = .unauthorized
        var isLoading = false
        var alert: AlertState<Action>?
        
        var isShowingWebView = false
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
        case logInButtonTapped
        case userResponse(TaskResult<User>)
        case webViewDismissed
        case tokenResponse(String)
        case alertDismissTapped
    }

    @Dependency(\.minderaPeopleService) var minderaPeopleService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logInButtonTapped:
                state.isShowingWebView = true
                
            case let .tokenResponse(token):
                UserDefaults.standard.set(token, forKey: "Token")
                state.isShowingWebView = false
                state.isLoading = true
                return .task {
                    await .userResponse(
                        TaskResult {
                            try await minderaPeopleService.user()
                        }
                    )
                }
                
            case let .userResponse(.failure(error)):
                state.isLoading = false
                state.alert = AlertState.configure(message: error.localizedDescription,
                                                   defaultAction: .logInButtonTapped,
                                                   cancelAction: .alertDismissTapped)

            case let .userResponse(.success(user)):
                state.isLoading = false
                state.signInState = .authorized(user)
                
            case .webViewDismissed:
                state.isShowingWebView = false

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
                    MinderaButton(.title(String(localized: "login",
                                                table: "LoginLocalizable"))) {
                        viewStore.send(.logInButtonTapped)
                    }
                    .contentMode(.fill)
                    .padding(.horizontal, 40)
                    .alert(
                        self.store.scope(state: \.alert),
                        dismiss: .alertDismissTapped
                    )
                    .sheet(isPresented:
                            viewStore.binding(
                        get: \.isShowingWebView,
                        send: .webViewDismissed
                    )) {
                        WebView(request: URLRequest(url: URL(string: "https://people.mindera.com/auth/google?mobile=ios")!)) { token in
                            viewStore.send(.tokenResponse(token))
                        }
                    }
                }
            }
            .padding()
            .navigationBarBackButtonHidden()
            .navigationDestination(
                isPresented:
                        .init(
                            get: { viewStore.signInState.isAuthorized },
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
