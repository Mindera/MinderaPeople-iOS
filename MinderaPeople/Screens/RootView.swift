//

import ComposableArchitecture
import SwiftUI

struct RootFeature: ReducerProtocol {
    struct State: Equatable {
        var isShowingHomePage = false
    }

    enum Action: Equatable {
        case logInButtonTapped
        case homePageDismiss
    }

//    Dependency example:
//    @Dependency(\.date) var date

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logInButtonTapped:
                state.isShowingHomePage = true
                return .none

            case .homePageDismiss:
                state.isShowingHomePage = false
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
                    Button {
                        viewStore.send(.logInButtonTapped)
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
                            get: \.isShowingHomePage,
                            send: .homePageDismiss
                        )
                ) { homePage }
            }
        }
    }

    @ViewBuilder
    var homePage: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .foregroundColor(.yellow)

            Text("Welcome 🚀")
                .font(.title)
        }
    }
}

extension RootFeature.State {
    static func mock(isShowingHomePage: Bool = false) -> Self {
        .init(isShowingHomePage: isShowingHomePage)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let feature = RootFeature()
        RootView(store: .init(initialState: .mock(), reducer: feature.body))
    }
}
