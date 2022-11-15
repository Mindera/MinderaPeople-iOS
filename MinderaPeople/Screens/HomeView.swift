//

import SwiftUI
import ComposableArchitecture

struct HomeFeature: ReducerProtocol {
    struct State: Equatable {
        var rootAction: RootFeature.Action?
    }

    enum Action: Equatable {
        case logOutButtonTapped
    }
    
    @Dependency(\.authenticationService) var authenticationService
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logOutButtonTapped:
                return .none
            }
        }
    }
    
}

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let feature = HomeFeature()
        HomeView(store: .init(initialState: .init(), reducer: feature.body))
    }
}

