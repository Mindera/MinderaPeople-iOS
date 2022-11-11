//

import ComposableArchitecture
import Firebase
import GoogleSignIn
import SwiftUI

struct RootFeature: ReducerProtocol {
    struct State: Equatable {
        var signInState: SignInState = .unauthorized
    }

    enum SignInState: Equatable {
        case authorized(User)
        case unauthorized
    }

    enum Action: Equatable {
        case logInButtonTapped
        case signInResponse(TaskResult<User>)
        case logOutButtonTapped
        case signOutResponse
        case homePageDismiss
    }

    @Dependency(\.authenticationService) var authenticationService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logInButtonTapped:
                return .task {
                    await .signInResponse(
                        TaskResult {
                            try await authenticationService.signIn()
                        }
                    )
                }

            case .signInResponse(.failure):
                // TODO: Login failure. Add some feedback to user
                return .none

            case let .signInResponse(.success(user)):
                state.signInState = .authorized(user)
                return .none

            case .logOutButtonTapped:
                return .task {
                    try? await authenticationService.signOut()
                    return .signOutResponse
                }

            case .signOutResponse:
                state.signInState = .unauthorized
                return .none

            case .homePageDismiss:
                return .none
            }
        }
    }
}

struct RootView: View {
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
                    GoogleSignInButton()
                        .frame(height: 48)
                        .onTapGesture {
                            viewStore.send(.logInButtonTapped)
                        }
                }
                .padding()
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
                ) { homePage }
            }
        }
    }

    // TODO: this should be removed to another view / file
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
                        viewStore.send(.logOutButtonTapped)
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
        .navigationBarBackButtonHidden()
    }
}

extension RootFeature.State {
    static func mock(signInState: RootFeature.SignInState = .unauthorized) -> Self {
        .init(signInState: signInState)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let feature = RootFeature()
        RootView(store: .init(initialState: .mock(), reducer: feature.body))
    }
}
