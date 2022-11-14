import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    private let store = StoreOf<BiometricAuthenticatorFeature>(initialState: .init(), reducer: BiometricAuthenticatorFeature().body)

    var body: some Scene {
        WindowGroup {
            LocalAuthenticatorView(store: store)
        }
    }
}
