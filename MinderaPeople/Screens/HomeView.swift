import ComposableArchitecture
import SwiftUI

struct HomeFeature: ReducerProtocol {
    struct State: Equatable {
        var isPresented = true
        var alert: AlertState<Action>?
    }

    enum Action: Equatable {
        case logOutButtonTapped
        case alertDismissTapped
    }
    
    var loginStateChanged: (_ newState: RootFeature.SignInState) -> Void

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logOutButtonTapped:
                UserDefaults.standard.removeObject(forKey: "Token")
                loginStateChanged(.unauthorized)
                
            case .alertDismissTapped:
                state.alert = nil
            }

            return .none
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
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: .init(
            initialState: .init(),
            reducer: HomeFeature(loginStateChanged: { _ in })
        ))
    }
}
