import ComposableArchitecture
import Foundation
import LocalAuthentication
import UserDefaultsClient

enum BiometricAuthenticatorError: Error {
    case userCancelled(Error?)
    case biometricNotEnrolled(Error?)
    case biometricAuthenticationNotEnabled
}

extension BiometricAuthenticatorClient: DependencyKey {
    public static var liveValue: Self {
        let userDefaults = UserDefaultsClient.liveValue
        let biometricAuthenticator = BiometricAuthenticator(userDefaults: userDefaults)
        return Self(
            biometricAuthenticationEnabled: { userDefaults.isBiometricAuthenticationEnabled },
            authenticate: { force in try await biometricAuthenticator.authenticate(force: force) },
            setAuthenticationTimeLimit: { limit in await biometricAuthenticator.setAuthenticationTimeLimit(limit) },
            enableBiometricAuthentication: { enable in await userDefaults.setBiometricAuthenticationEnabled(enable) },
            updateLastSuccessfulAuthenticationDate: { date in await userDefaults.setLastBiometricAuthenticationDate(date) }
        )
    }
}

public actor BiometricAuthenticator {
    private var authenticationTimeLimit: TimeInterval = 0
    private let userDefaults: UserDefaultsClient
    private let referenceDate: Date
    private let context: LAContext

    init(authenticationContext: LAContext = LAContext(),
         userDefaults: UserDefaultsClient,
         referenceDate: Date = Date()) {
        self.context = authenticationContext
        self.userDefaults = userDefaults
        self.referenceDate = referenceDate
    }

    func setAuthenticationTimeLimit(_ limit: TimeInterval) async {
        authenticationTimeLimit = limit
    }

    func authenticate(force: Bool) async throws -> Bool {
        guard userDefaults.isBiometricAuthenticationEnabled else { return false }

        if
            !force,
            let lastAuthenticationDate = userDefaults.lastBiometricAuthenticationDate {
            let elapsedTime = referenceDate.timeIntervalSince(lastAuthenticationDate)
            if elapsedTime < authenticationTimeLimit {
                return true
            }
        }

        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            do {
                return try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    // TODO: Add localization
                    localizedReason: "We need to verify your identity"
                )
            } catch {
                throw BiometricAuthenticatorError.userCancelled(error)
            }
        } else {
            throw BiometricAuthenticatorError.biometricNotEnrolled(error)
        }
    }
}
