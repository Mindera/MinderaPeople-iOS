import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    private let store = StoreOf<LocalAuthenticatorFeature>(initialState: .init(), reducer: LocalAuthenticatorFeature().body)

    var body: some Scene {
        WindowGroup {
            LocalAuthenticatorView(store: store)
        }
    }
}
