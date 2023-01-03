import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let store = Store(
      initialState: Root.State(),
      reducer: Root()._printChanges()
    )

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
