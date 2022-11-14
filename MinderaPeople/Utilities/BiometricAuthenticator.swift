
import ComposableArchitecture
import LocalAuthentication
import SwiftUI

enum BiometricAuthenticatorError: Error, Equatable {
    case userCancelled(String)
    case biometricNotEnrolled(String)
}

struct BiometricAuthenticatorFeature: ReducerProtocol {
    private let context = LAContext()

    enum UserDefaultsKeys: String {
        case biometricAuthenticationEnabled
        case lastAuthenticationDate
    }

    struct State: Equatable {
        var isAuthenticated: Bool = false
        var authenticationTimeLimit: TimeInterval
        var text: String { isAuthenticated ? "Unlocked" : "Locked" }
        var textColor: Color { isAuthenticated ? .green : .red }
        var authenticationEnabled: Bool { UserDefaults.standard.bool(forKey: UserDefaultsKeys.biometricAuthenticationEnabled.rawValue) }
    }

    enum Action {
        case onAppear
        case authenticate
        case authenticateResponse(TaskResult<Bool>)
        case enableAuthenticationChanged(Bool)
    }

    @Dependency(\.mainQueue) var mainQueue
    @AppStorage(UserDefaultsKeys.lastAuthenticationDate.rawValue) private var lastAuthenticationDate: Date?

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.authenticationEnabled else { return .none }

                guard let lastAuthenticationDate = lastAuthenticationDate else {
                    return Effect(value: .authenticate)
                }
                // Authenticate the user only if 5 minutes passed since the last successful authentication
                let elapsedTime = Date().timeIntervalSince(lastAuthenticationDate)
                state.isAuthenticated = elapsedTime < state.authenticationTimeLimit
                return state.isAuthenticated ? .none : Effect(value: .authenticate)

            case .authenticate:
                return .task {
                    await .authenticateResponse(
                        TaskResult {
                            try await authenticate()
                        }
                    )
                }

            case let .authenticateResponse(.success(authenticated)):
                state.isAuthenticated = authenticated
                lastAuthenticationDate = authenticated ? Date() : nil
                return .none

            case let .authenticateResponse(.failure(error)):
                print("Received error: \(error)")
                return .none

            case .enableAuthenticationChanged(let enabled):
                if !enabled {
                    lastAuthenticationDate = nil
                    state.isAuthenticated = false
                }
                UserDefaults.standard.set(enabled, forKey: UserDefaultsKeys.biometricAuthenticationEnabled.rawValue)
                return .none
            }
        }
    }

    private func authenticate() async throws -> Bool {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            do {
                return try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "We need to verify your identity"
                )
            } catch {
                throw BiometricAuthenticatorError.userCancelled(error.localizedDescription)
            }
        } else {
            throw BiometricAuthenticatorError.biometricNotEnrolled(error?.localizedDescription ?? "")
        }
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
