import ComposableArchitecture
import MinderaDesignSystem
import SwiftUI

struct LoginView: View {
    let store: StoreOf<Login>

    init(store: StoreOf<Login>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
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
                    if let userApiUrl = viewStore.state.userApiUrl {
                        WebView(request: URLRequest(url: userApiUrl)) { token in
                            viewStore.send(.tokenResponse(token))
                        }
                    }
                }
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
