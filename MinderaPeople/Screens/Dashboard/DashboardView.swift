import ComposableArchitecture
import SwiftUI
import MinderaDesignSystem

struct DashboardView: View {
    let store: StoreOf<Dashboard>
    @ObservedObject var viewStore: ViewStoreOf<Dashboard>
    
    init(store: StoreOf<Dashboard>) {
        self.store = store
        viewStore = .init(store)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text(viewStore.greetingMessage)
                        .foregroundColor(Color.greyBlue(._900))
                        .customFont(size: .XL, weight: .bold)
                    Spacer()
                    Button {
                        // TODO: Add notifications screen redirection
                    } label: {
                        Image(viewStore.notificationsIconName)
                    }
                }.padding(EdgeInsets(top: 40, leading: 16, bottom: 0, trailing: 16))
                Spacer()
            }
            .background(Color.greyBlue(._000))
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
        .navigationBarHidden(true)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(store: .init(initialState: .init(), reducer: Dashboard()))
    }
}
