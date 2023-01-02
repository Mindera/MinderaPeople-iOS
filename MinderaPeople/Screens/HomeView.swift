import ComposableArchitecture
import MinderaDesignSystem
import SwiftUI

struct HomeFeature: ReducerProtocol {
    struct State: Equatable {
        var isPresented = true
        var alert: AlertState<Action>?
        var selectedTab: Tab = .dashboard
    }

    enum Tab {
        case dashboard
        case calendar
        case myProfile
    }

    enum Action: Equatable {
        case logOutButtonTapped
        case signOutResponse(TaskResult<VoidEquatable>)
        case alertDismissTapped
        case tabButtonPressed(Tab)
    }

    @Dependency(\.authenticationService) var authenticationService

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logOutButtonTapped:
                return .task {
                    await .signOutResponse(
                        TaskResult {
                            try await authenticationService.signOut()
                        }
                    )
                }

            case let .signOutResponse(.failure(error)):
                let error = AuthenticationServiceError.googleSignOutFailure(error)
                state.alert = AlertState.configure(message: error.localizedDescription,
                                                   defaultAction: .logOutButtonTapped,
                                                   cancelAction: .alertDismissTapped)

            case .signOutResponse(.success):
                state.isPresented = false

            case .alertDismissTapped:
                state.alert = nil

            case let .tabButtonPressed(tab):
                state.selectedTab = tab
            }

            return .none
        }
    }
}

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    @ObservedObject var viewStore: ViewStoreOf<HomeFeature>

    init(store: StoreOf<HomeFeature>) {
        self.store = store
        viewStore = .init(store)
    }

    var body: some View {
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
            icon: icon(.dashboard),
            text: text(.dashboard)
        )
        .tab(
            .calendar,
            content: {
                Text("Calendar")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.yellow(._100))
            },
            icon: icon(.calendar),
            text: text(.calendar)
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
            icon: icon(.myProfile),
            text: text(.myProfile)
        )
        .shadow(radius: 1)
        .navigationBarBackButtonHidden()
        .navigationDestination(
            isPresented:
            .init(
                get: { !viewStore[keyPath: \.isPresented] },
                set: { _ in }
            )
        ) {
            LoginView(store: .init(initialState: .init(), reducer: LoginFeature()))
        }
    }

    private func icon(_ selectionValue: HomeFeature.Tab) -> some View {
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

    private func text(_ selectionValue: HomeFeature.Tab) -> some View {
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
        HomeView(store: .init(initialState: .init(), reducer: HomeFeature()))
    }
}
