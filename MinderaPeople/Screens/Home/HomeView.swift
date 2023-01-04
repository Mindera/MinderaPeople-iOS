import ComposableArchitecture
import MinderaDesignSystem
import SwiftUI

struct HomeView: View {
    let store: StoreOf<Home>
    
    init(store: StoreOf<Home>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            TabBarView(
                selection: viewStore.binding(
                    get: { $0.selectedTab },
                    send: { .tabButtonPressed($0) }
                )
            )
            .tab(
                .dashboard,
                content: {
                    Text("Dashboard")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.red(._100))
                },
                icon: icon(.dashboard, viewStore),
                text: text(.dashboard, viewStore)
            )
            .tab(
                .calendar,
                content: {
                    Text("Calendar")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.yellow(._100))
                },
                icon: icon(.calendar, viewStore),
                text: text(.calendar, viewStore)
            )
            .tab(
                .myProfile,
                content: {
                    Button {
                        viewStore.send(.logOutButtonTapped)
                    } label: {
                        Text("Log Out")
                            .foregroundColor(.yellow)
                            .padding()
                            .background {
                                Capsule()
                                    .foregroundColor(.black)
                            }
                    }
                },
                icon: icon(.myProfile, viewStore),
                text: text(.myProfile, viewStore)
            )
            .shadow(radius: 1)
            .navigationBarBackButtonHidden()
        }
    }
    
    private func icon(_ selectionValue: Home.Tab,
                      _ viewStore: ViewStore<Home.State, Home.Action>) -> some View {
        var name = ""
        switch selectionValue {
        case .dashboard:
            name = "dashboard"
        case .calendar:
            name = "calendar"
        case .myProfile:
            name = "myProfile"
        }
        return Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(viewStore.selectedTab == selectionValue ? Color.indigo(._600) : Color.greyBlue(._500))
    }
    
    private func text(_ selectionValue: Home.Tab,
                      _ viewStore: ViewStore<Home.State, Home.Action>) -> some View {
        var text = ""
        switch selectionValue {
        case .dashboard:
            text = "Dashboard"
        case .calendar:
            text = "Calendar"
        case .myProfile:
            text = "My Profile"
        }
        return Text(text)
            .customFont(size: .XS)
            .foregroundColor(viewStore.selectedTab == selectionValue ? Color.indigo(._600) : Color.greyBlue(._500))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: .init(
            initialState: Home.State(),
            reducer: Home()
        ))
    }
}
