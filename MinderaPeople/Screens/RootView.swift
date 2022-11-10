//

import ComposableArchitecture
import SwiftUI
import Firebase
import GoogleSignIn

struct RootFeature: ReducerProtocol {
    struct State: Equatable {
        var isUserSignedIn = false
    }

    enum Action: Equatable {
        case logInButtonTapped
        case homePageDismiss
    }

//    Dependency example:
//    @Dependency(\.date) var date
//    @Dependency(\.authenticationClient) var authenticationClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logInButtonTapped:
                state.isUserSignedIn = true
                return .none

            case .homePageDismiss:
                state.isUserSignedIn = false
                return .none
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var viewModel: UserAuthModel
    
    let store: StoreOf<RootFeature>
    var body: some View {
        NavigationStack {
            WithViewStore(store) { viewStore in
                VStack {
                    Spacer()
                    VStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                        Text("Hello, world!")
                    }
                    Spacer()
                    Button {
                        viewModel.signIn(presentingController: getRootViewController()) {
                            viewStore.send(.logInButtonTapped)
                        }
                    } label: {
                        Text("Log In with google")
                            .foregroundColor(.black)
                            .padding()
                            .background {
                                Capsule()
                                    .foregroundColor(.yellow)
                            }
                    }
                }
                .padding()
                .navigationDestination(
                    isPresented: viewStore
                        .binding(
                            get: \.isUserSignedIn,
                            send: .homePageDismiss
                        )
                ) { homePage }
            }
        }
    }

    @ViewBuilder
    var homePage: some View {
        ZStack {
            WithViewStore(store) { viewStore in
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .foregroundColor(.yellow)
                VStack {
                    Text("Welcome 🚀")
                        .font(.title)
                    Spacer()
                    Button {
                        viewModel.signOut()
                        viewStore.send(.homePageDismiss)
                    } label: {
                        Text("Log Out")
                            .foregroundColor(.yellow)
                            .padding()
                            .background {
                                Capsule()
                                    .foregroundColor(.black)
                            }
                    }
                }.padding()
            }
        }
    }
}

extension RootFeature.State {
    static func mock(isShowingHomePage: Bool = true) -> Self {
        .init(isUserSignedIn: isShowingHomePage)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let feature = RootFeature()
        RootView(store: .init(initialState: .mock(), reducer: feature.body))
    }
}

extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
