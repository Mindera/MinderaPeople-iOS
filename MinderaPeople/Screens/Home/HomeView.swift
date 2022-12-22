import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: StoreOf<Home>

    struct ViewState: Equatable {
        var alert: AlertState<Home.Action>?
        
        init(state: Home.State) {
            self.alert = state.alert
        }
    }
    
    enum ViewAction {
        case logOutButtonTapped
        case alertDismissTapped
    }
    
    init(store: StoreOf<Home>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: ViewState.init, send: Home.Action.init) { viewStore in
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
}

extension Home.Action {
    init(action: HomeView.ViewAction) {
        switch action {
        case .logOutButtonTapped:
            self = .logOutButtonTapped
        case .alertDismissTapped:
            self = .alertDismissTapped
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: .init(
            initialState: Home.State(),
            reducer: Home()
        ))
    }
}
