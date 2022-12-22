import ComposableArchitecture
import MinderaPeople_iOS_DesignSystem
import SwiftUI

struct RootView: View {
  let store: StoreOf<Root>

  public init(store: StoreOf<Root>) {
    self.store = store
  }

  public var body: some View {
    SwitchStore(self.store) {
      CaseLet(state: /Root.State.login, action: Root.Action.login) { store in
        NavigationView {
          LoginView(store: store)
        }
        .navigationViewStyle(.stack)
      }
      CaseLet(state: /Root.State.home, action: Root.Action.home) { store in
        NavigationView {
          HomeView(store: store)
        }
        .navigationViewStyle(.stack)
      }
    }
  }
}
