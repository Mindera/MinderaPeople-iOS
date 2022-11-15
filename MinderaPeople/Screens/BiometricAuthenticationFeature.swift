import ComposableArchitecture
import SwiftUI

struct BiometricAuthenticationFeature: ReducerProtocol {
    
    struct State: Equatable {
        var isAuthenticated: Bool = false
        var text: String { isAuthenticated ? "Unlocked" : "Locked" }
        var textColor: Color { isAuthenticated ? .green : .red }
        var authenticationEnabled: Bool = false
    }
    
    enum Action {
        case onAppear
        case authenticate
        case authenticateResponse(TaskResult<Bool>)
        case enableAuthenticationChanged(Bool)
    }

    @Dependency(\.biometricAuthenticator) var biometricAuthenticator
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.authenticationEnabled = biometricAuthenticator.biometricAuthenticationEnabled()
                return .run { send in
                    await biometricAuthenticator.setAuthenticationTimeLimit(300)
                }
  
            case .authenticate:
                return .task {
                    await .authenticateResponse(
                        TaskResult {
                            try await biometricAuthenticator.authenticate()
                        }
                    )
                }
                
            case let .authenticateResponse(.success(authenticated)):
                state.isAuthenticated = authenticated
                return .run { _ in
                    await biometricAuthenticator.updateLastSuccessfulAuthenticationDate(authenticated ? Date() : nil)
                }
                
            case let .authenticateResponse(.failure(error)):
                print("Received error: \(error)")
                return .none
                
            case .enableAuthenticationChanged(let enabled):
                state.authenticationEnabled = enabled
                return .run { send in
                    if !enabled {
                        await biometricAuthenticator.updateLastSuccessfulAuthenticationDate(nil)
                    }
                    await biometricAuthenticator.enableBiometricAuthentication(enabled)
                }
            }
        }
    }
}
