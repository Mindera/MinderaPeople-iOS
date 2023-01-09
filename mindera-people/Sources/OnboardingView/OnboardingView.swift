import ComposableArchitecture
import SwiftUI
import OnboardingCore

public struct OnboardingView: View {
    let store: StoreOf<Onboarding>
    
    public init(store: StoreOf<Onboarding>) {
        self.store = store
    }
    
    public var body: some View {
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
