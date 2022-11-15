import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    private let store = StoreOf<BiometricAuthenticationFeature>(initialState: .init(), reducer: BiometricAuthenticationFeature().body)

    var body: some Scene {
        WindowGroup {
            LocalAuthenticatorView(store: store)
        }
    }
}
