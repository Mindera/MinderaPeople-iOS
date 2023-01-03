import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: StoreOf<Home>

    init(store: StoreOf<Home>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .foregroundColor(.yellow)
                VStack {
                    Text("Welcome 🚀")
                        .font(.title)
                    Spacer()
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
                }
                .padding()
            }
            .navigationBarBackButtonHidden()
        }
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
