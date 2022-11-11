//

import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    private let feature = RootFeature()

    var body: some Scene {
        WindowGroup {
            RootView(store: .init(initialState: .init(), reducer: feature.body))
        }
    }
}
