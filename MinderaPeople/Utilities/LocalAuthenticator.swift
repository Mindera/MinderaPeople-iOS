
import ComposableArchitecture
import SwiftUI
import LocalAuthentication

enum LocalAuthenticatorError: Error, Equatable {
    case somethingWentWrong(String)
}

struct LocalAuthenticatorFeature: ReducerProtocol {
    
    struct State: Equatable {
        var isAuthenticated: Bool = false
        var text: String { isAuthenticated ? "Unlocked" : "Locked" }
        var textColor: Color { isAuthenticated ? .green : .red }
    }
    
    enum Action {
        case onAppear
        case authenticate
        case authenticationFinished(Result<Bool, LocalAuthenticatorError>)
    }

    @Dependency(\.mainQueue) var mainQueue
    @AppStorage("lastAuthenticationDate") private var lastAuthenticationDate: Date?
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let lastAuthenticationDate = lastAuthenticationDate else {
                    return Effect(value: .authenticate)
                }
                //Authenticate the user only if 5 minutes passed since the last successful authentication
                let elapsedTime = Date().timeIntervalSince(lastAuthenticationDate)
                state.isAuthenticated = elapsedTime < 300
                return state.isAuthenticated ? .none :  Effect(value: .authenticate)
            case .authenticate:
                return authenticate()
                        .receive(on: mainQueue)
                        .catchToEffect(Action.authenticationFinished)
            case let .authenticationFinished(.success(authenticated)):
                state.isAuthenticated = authenticated
                lastAuthenticationDate = authenticated ? Date() : nil
                return .none
            case let .authenticationFinished(.failure(error)):
                print("Received error: \(error)")
                return .none
            }
        }
    }
    
    func authenticate() -> Effect<Bool, LocalAuthenticatorError> {
        EffectTask.task {
            let context = LAContext()
            var error: NSError?
            // Check whether biometric authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                do {
                    return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We need to verify your identity")
                } catch {
                    throw LocalAuthenticatorError.somethingWentWrong(error.localizedDescription)
                }
            } else {
                throw LocalAuthenticatorError.somethingWentWrong(error?.localizedDescription ?? "")
            }
        }
        .setFailureType(to: LocalAuthenticatorError.self)
        .eraseToEffect()
    }
}

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}
