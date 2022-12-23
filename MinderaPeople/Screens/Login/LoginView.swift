import ComposableArchitecture
import MinderaPeople_iOS_DesignSystem
import SwiftUI

struct LoginView: View {
    let store: StoreOf<Login>
    
    struct ViewState: Equatable {
        var isLoading: Bool
        var alert: AlertState<Login.Action>?
        var isShowingWebView: Bool
        
        init(state: Login.State) {
            self.alert = state.alert
            self.isLoading = state.isLoading
            self.isShowingWebView = state.isShowingWebView
        }
    }
    
    enum ViewAction {
        case logInButtonTapped
        case userResponse(TaskResult<User>)
        case webViewDismissed
        case tokenResponse(String)
        case alertDismissTapped
    }
    
    init(store: StoreOf<Login>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init, send: Login.Action.init) { viewStore in
            NavigationStack {
                Group {
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
}

extension Login.Action {
  init(action: LoginView.ViewAction) {
    switch action {
    case .logInButtonTapped:
        self = .logInButtonTapped
    case let .userResponse(user):
        self = .userResponse(user)
    case .webViewDismissed:
        self = .webViewDismissed
    case let .tokenResponse(token):
        self = .tokenResponse(token)
    case .alertDismissTapped:
        self = .alertDismissTapped
    }
  }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(store: .init(
            initialState: Login.State(),
            reducer: Login()
        ))
    }
}
