import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {
    let store: StoreOf<Onboarding>

    struct ViewState: Equatable {
        var appState: Onboarding.AppState?
        
        init(state: Onboarding.State) {
            self.appState = state.appState
        }
    }
    
    enum ViewAction {
        case onAppear
        case userResponse(TaskResult<User>)
    }
    
    init(store: StoreOf<Onboarding>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: ViewState.init, send: Onboarding.Action.init) { viewStore in
            VStack {
                Spacer()
                Image("minderaLogo")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Spacer()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

extension Onboarding.Action {
    init(action: OnboardingView.ViewAction) {
        switch action {
        case .onAppear:
            self = .onAppear
        case let .userResponse(result):
            self = .userResponse(result)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: .init(
            initialState: Onboarding.State(),
            reducer: Onboarding()
        ))
    }
}

