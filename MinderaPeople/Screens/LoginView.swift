import ComposableArchitecture
import WebKit
import MinderaPeople_iOS_DesignSystem
import SwiftUI

struct LoginFeature: ReducerProtocol {
    struct State: Equatable {
        var isLoading = false
        var alert: AlertState<Action>?
        
        var isShowingWebView = false
    }

    enum Action: Equatable {
        case logInButtonTapped
        case userResponse(TaskResult<User>)
        case webViewDismissed
        case tokenResponse(String)
        case alertDismissTapped
    }
    
    var loginStateChanged: (_ newState: RootFeature.SignInState) -> Void

    @Dependency(\.minderaPeopleService) var minderaPeopleService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logInButtonTapped:
                state.isShowingWebView = true
                state.isLoading = true
                
            case let .tokenResponse(token):
                UserDefaults.standard.set(token, forKey: "Token")
                state.isShowingWebView = false
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
                loginStateChanged(.authorized(user))
                
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
            content
                .navigationBarBackButtonHidden()
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
    
    @ViewBuilder
    private var content: some View {
        if viewStore.isLoading {
            LoaderView()
        } else {
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
            }
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .alertDismissTapped
            )
        }
    }
}

extension LoginFeature.State {
    static func mock() -> Self {
        .init()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(store: .init(
            initialState: .mock(),
            reducer: LoginFeature(loginStateChanged: { _ in })
        ))
    }
}
