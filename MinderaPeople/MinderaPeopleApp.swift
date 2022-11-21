//

import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    private let feature = LoginFeature()

    var body: some Scene {
        WindowGroup {
            LoginView(store: .init(initialState: .init(), reducer: feature))
        }
    }
}
