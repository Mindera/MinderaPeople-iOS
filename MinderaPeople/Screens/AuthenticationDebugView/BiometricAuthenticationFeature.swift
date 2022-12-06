import ComposableArchitecture
import SwiftUI
import AlicerceLogging

struct BiometricAuthenticationFeature: ReducerProtocol {
    
    struct State: Equatable {
        var isAuthenticated: Bool = false
        // TODO: Add localization
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
    @Dependency(\.date) var date
    @Dependency(\.logger) var logger
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let isAuthenticationEnabled = biometricAuthenticator.biometricAuthenticationEnabled()
                state.authenticationEnabled = isAuthenticationEnabled
                guard isAuthenticationEnabled else {
                    return .none
                }
                return .task {
                    await biometricAuthenticator.setAuthenticationTimeLimit(300)
                    return .authenticate
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
                    await biometricAuthenticator.updateLastSuccessfulAuthenticationDate(authenticated ? date() : nil)
                }
                
            case let .authenticateResponse(.failure(error)):
                logger.logError(error.localizedDescription)
                return .none
                
            case let .enableAuthenticationChanged(enabled):
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
