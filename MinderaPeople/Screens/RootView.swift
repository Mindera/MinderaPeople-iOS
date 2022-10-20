//
//  RootView.swift
//  MinderaPeople
//
//  Created by Mindera on 06/10/2022.
//

import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
    var isShowingHomePage = false
}

struct AppEnvironment {
}

enum AppAction: Equatable {
    case logInButtonTapped
    case homePageDismiss
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
    switch action {
    case .logInButtonTapped:
        state.isShowingHomePage = true
        return .none
    case .homePageDismiss:
        state.isShowingHomePage = false
        return .none
    }
}

struct RootView: View {
    let store: Store<AppState, AppAction>
    var body: some View {
        NavigationStack {
            WithViewStore(store) { viewStore in
                VStack {
                    Spacer()
                    VStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                        Text("Hello, world!")
                    }
                    Spacer()
                    
                    Button {
                        viewStore.send(.logInButtonTapped)
                    } label: {
                        Text("Log In with google")
                            .foregroundColor(.black)
                            .padding()
                            .background {
                                Capsule()
                                    .foregroundColor(.yellow)
                            }
                    }
                }
                .padding()
                .navigationDestination(
                    isPresented: viewStore.binding(
                        get: \.isShowingHomePage,
                        send: .homePageDismiss
                    )
                ) { homePage }
            }
            
        }
    }
    
    @ViewBuilder
    var homePage: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .foregroundColor(.yellow)
            
            Text("Welcome 🚀")
                .font(.title)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: .init(
                initialState: AppState(),
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
    }
}
