//

import SwiftUI
import ComposableArchitecture

struct LocalAuthenticatorView: View {
    let store: StoreOf<BiometricAuthenticatorFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(viewStore.text)
                    .foregroundColor(viewStore.textColor)
                Toggle("Enable biometric authentication",
                       isOn: viewStore.binding(get: \.authenticationEnabled, send: BiometricAuthenticatorFeature.Action.enableAuthenticationChanged))
                    .padding()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

extension BiometricAuthenticatorFeature.State {
    static func mock(isAuthenticated: Bool = true) -> Self {
        .init(isAuthenticated: isAuthenticated)
    }
}
struct LocalAuthenticatorView_Previews: PreviewProvider {
    static var previews: some View {
        let feature = BiometricAuthenticatorFeature()
        LocalAuthenticatorView(store: .init(initialState: .mock(),
                                            reducer: feature.body))
    }
}
