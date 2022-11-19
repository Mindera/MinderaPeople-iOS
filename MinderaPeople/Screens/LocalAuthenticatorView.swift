//

import ComposableArchitecture
import SwiftUI

struct LocalAuthenticatorView: View {
    let store: StoreOf<BiometricAuthenticationFeature>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(viewStore.text)
                    .foregroundColor(viewStore.textColor)
                Toggle("Enable biometric authentication",
                       isOn: viewStore.binding(
                           get: \.authenticationEnabled,
                           send: { .enableAuthenticationChanged($0) }
                       )
                )
                .padding()
            }
            .onAppear {
                viewStore.send(.onAppear)
                viewStore.send(.authenticate)
            }
        }
    }
}

extension BiometricAuthenticationFeature.State {
    static func mock(isAuthenticated: Bool = true) -> Self {
        .init(isAuthenticated: isAuthenticated)
    }
}

struct LocalAuthenticatorView_Previews: PreviewProvider {
    static var previews: some View {
        LocalAuthenticatorView(
            store: .init(
                initialState: .mock(),
                reducer: BiometricAuthenticationFeature()
            )
        )
    }
}
