//

import ComposableArchitecture
import SwiftUI

struct HomeFeature: ReducerProtocol {
    struct State: Equatable {
        var isPresented = true
        var alert: AlertState<Action>?
    }

    enum Action: Equatable {
        case logOutButtonTapped
        case signOutResponseSuccess
        case signOutResponseFailure(AuthenticationServiceError)
        case alertDismissTapped
        case noAction
    }

    @Dependency(\.authenticationService) var authenticationService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logOutButtonTapped:
                return .task {
                    do {
                        try await authenticationService.signOut()
                    } catch {
                        return .signOutResponseFailure(.googleSignOutFailure(error.localizedDescription))
                    }
                    return .signOutResponseSuccess
                }

            case .signOutResponseSuccess:
                state.isPresented = false
                return .none

            case let .signOutResponseFailure(error):
                state.alert = AlertState(
                    title: TextState("Something went wrong"),
                    message: TextState(error.localizedDescription),
                    primaryButton: .default(TextState("Retry"), action: .send(.logOutButtonTapped)),
                    secondaryButton: .cancel(TextState("Ok"), action: .send(.alertDismissTapped))
                )
                return .none

            case .alertDismissTapped:
                state.alert = nil
                return .none
                
            case .noAction:
                return .none
            }
        }
    }
}

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    @ObservedObject var viewStore: ViewStoreOf<HomeFeature>

    init(store: StoreOf<HomeFeature>) {
        self.store = store
        viewStore = .init(store)
    }

    var body: some View {
        ZStack {
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
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(
            isPresented: viewStore
                .binding(
                    get: { !$0.isPresented },
                    send: .noAction
                )
        ) {
            LoginView(store: .init(initialState: .init(), reducer: LoginFeature()))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: .init(initialState: .init(), reducer: HomeFeature()))
    }
}
