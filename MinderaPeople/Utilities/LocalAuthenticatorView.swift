//

import SwiftUI
import ComposableArchitecture

struct LocalAuthenticatorView: View {
    let store: StoreOf<LocalAuthenticatorFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(viewStore.text)
                    .foregroundColor(viewStore.textColor)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

extension LocalAuthenticatorFeature.State {
    static func mock(isAuthenticated: Bool = true) -> Self {
        .init(isAuthenticated: isAuthenticated)
    }
}
struct LocalAuthenticatorView_Previews: PreviewProvider {
    static var previews: some View {
        let feature = LocalAuthenticatorFeature()
        LocalAuthenticatorView(store: .init(initialState: .mock(),
                                            reducer: feature.body))
    }
}
