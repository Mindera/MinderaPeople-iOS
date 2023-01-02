import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {
    let store: StoreOf<Onboarding>
    
    init(store: StoreOf<Onboarding>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
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

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: .init(
            initialState: Onboarding.State(),
            reducer: Onboarding()
        ))
    }
}

