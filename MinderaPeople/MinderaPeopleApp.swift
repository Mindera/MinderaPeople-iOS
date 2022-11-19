import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    private let store = StoreOf<RootReducer>(initialState: .init(), reducer: RootReducer())

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
