import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    private let feature = RootFeature()

    var body: some Scene {
        WindowGroup {
            RootView(store: .init(initialState: .init(), reducer: feature.body))
        }
    }
}
