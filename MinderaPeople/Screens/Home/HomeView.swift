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
                icon: icon(.dashboard, isHighlighted: viewStore.selectedTab == .dashboard),
                text: text(.dashboard, isHighlighted: viewStore.selectedTab == .dashboard)
            )
            .tab(
                .calendar,
                content: {
                    Text("Calendar")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.yellow(._100))
                },
                icon: icon(.calendar, isHighlighted: viewStore.selectedTab == .calendar),
                text: text(.calendar, isHighlighted: viewStore.selectedTab == .calendar)
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
                icon: icon(.myProfile, isHighlighted: viewStore.selectedTab == .myProfile),
                text: text(.myProfile, isHighlighted: viewStore.selectedTab == .myProfile)
            )
            .shadow(radius: 1)
            .navigationBarBackButtonHidden()
        }
    }
    
    private func icon(_ selectionValue: Home.Tab, isHighlighted: Bool) -> some View {
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
            .foregroundColor(isHighlighted ? Color.indigo(._600) : Color.greyBlue(._500))
    }
    
    private func text(_ selectionValue: Home.Tab, isHighlighted: Bool) -> some View {
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
            .foregroundColor(isHighlighted ? Color.indigo(._600) : Color.greyBlue(._500))
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
