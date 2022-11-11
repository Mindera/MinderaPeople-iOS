
import ComposableArchitecture
import LocalAuthentication
import SwiftUI

enum LocalAuthenticatorError: Error, Equatable {
    case userCancelled(String)
    case biometricNotEnrolled(String)
}

struct LocalAuthenticatorFeature: ReducerProtocol {
    private let context = LAContext()

    struct State: Equatable {
        var isAuthenticated: Bool = false
        var text: String { isAuthenticated ? "Unlocked" : "Locked" }
        var textColor: Color { isAuthenticated ? .green : .red }
    }

    enum Action {
        case onAppear
        case authenticate
        case authenticateResponse(TaskResult<Bool>)
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
                // Authenticate the user only if 5 minutes passed since the last successful authentication
                let elapsedTime = Date().timeIntervalSince(lastAuthenticationDate)
                state.isAuthenticated = elapsedTime < 300
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
                throw LocalAuthenticatorError.userCancelled(error.localizedDescription)
            }
        } else {
            throw LocalAuthenticatorError.biometricNotEnrolled(error?.localizedDescription ?? "")
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
