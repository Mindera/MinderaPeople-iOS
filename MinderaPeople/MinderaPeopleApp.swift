import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

#if DEBUG
    let store = Store(
      initialState: Root.State(),
      reducer: Root()._printChanges()
    )
#else
    let store = Store(
      initialState: Root.State(),
      reducer: Root()
    )
#endif

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
