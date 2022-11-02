//

import ComposableArchitecture
import SwiftUI

@main
struct MinderaPeopleApp: App {
    private let state = AppState()
    private let environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView(store: .init(initialState: state, reducer: appReducer, environment: environment))
        }
    }
}
