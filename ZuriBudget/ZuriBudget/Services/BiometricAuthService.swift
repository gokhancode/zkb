//
//  BiometricAuthService.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Biometric authentication service for Face ID/Touch ID protection

import Foundation
import LocalAuthentication

/// Service for handling biometric authentication (Face ID/Touch ID)
final class BiometricAuthService {

    // MARK: - Biometric Availability

    enum BiometricType {
        case faceID
        case touchID
        case none
    }

    enum AuthError: LocalizedError {
        case biometricNotAvailable
        case biometricNotEnrolled
        case authenticationFailed
        case userCancelled
        case passcodeNotSet
        case unknown(Error)

        var errorDescription: String? {
            switch self {
            case .biometricNotAvailable:
                return "Biometric authentication is not available on this device"
            case .biometricNotEnrolled:
                return "No biometric authentication is enrolled. Please set up Face ID or Touch ID in Settings"
            case .authenticationFailed:
                return "Authentication failed. Please try again"
            case .userCancelled:
                return "Authentication was cancelled"
            case .passcodeNotSet:
                return "Device passcode is not set. Please set a passcode in Settings"
            case .unknown(let error):
                return "Authentication error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Singleton

    static let shared = BiometricAuthService()

    private init() {}

    // MARK: - Public Methods

    /// Check what type of biometric authentication is available
    func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }

    /// Check if biometric authentication is available
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Authenticate user with biometrics (Face ID/Touch ID)
    /// - Returns: Success or throws AuthError
    func authenticate() async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = "Use Passcode"

        // Check if biometric authentication is available
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                switch error.code {
                case LAError.biometryNotAvailable.rawValue:
                    throw AuthError.biometricNotAvailable
                case LAError.biometryNotEnrolled.rawValue:
                    throw AuthError.biometricNotEnrolled
                case LAError.passcodeNotSet.rawValue:
                    throw AuthError.passcodeNotSet
                default:
                    throw AuthError.unknown(error)
                }
            }
            throw AuthError.biometricNotAvailable
        }

        // Attempt authentication
        let reason = "Authenticate to access your financial data"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            if !success {
                throw AuthError.authenticationFailed
            }
        } catch let laError as LAError {
            switch laError.code {
            case .userCancel, .appCancel, .systemCancel:
                throw AuthError.userCancelled
            case .authenticationFailed:
                throw AuthError.authenticationFailed
            case .biometryNotAvailable:
                throw AuthError.biometricNotAvailable
            case .biometryNotEnrolled:
                throw AuthError.biometricNotEnrolled
            case .passcodeNotSet:
                throw AuthError.passcodeNotSet
            default:
                throw AuthError.unknown(laError)
            }
        } catch {
            throw AuthError.unknown(error)
        }
    }

    /// Authenticate with fallback to device passcode
    /// More permissive - allows passcode if biometrics fail
    func authenticateWithPasscode() async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        let reason = "Authenticate to access your financial data"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication, // Allows passcode fallback
                localizedReason: reason
            )

            if !success {
                throw AuthError.authenticationFailed
            }
        } catch let laError as LAError {
            switch laError.code {
            case .userCancel, .appCancel, .systemCancel:
                throw AuthError.userCancelled
            case .authenticationFailed:
                throw AuthError.authenticationFailed
            case .passcodeNotSet:
                throw AuthError.passcodeNotSet
            default:
                throw AuthError.unknown(laError)
            }
        } catch {
            throw AuthError.unknown(error)
        }
    }

    /// Get user-friendly description of available biometric type
    func biometricTypeDescription() -> String {
        switch biometricType() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "Passcode"
        }
    }
}

// MARK: - UserDefaults Extension for Auth Preferences

extension UserDefaults {
    private enum Keys {
        static let biometricAuthEnabled = "biometricAuthEnabled"
        static let requireAuthOnLaunch = "requireAuthOnLaunch"
    }

    /// Check if user has enabled biometric authentication
    var isBiometricAuthEnabled: Bool {
        get {
            // Default to true for security
            if object(forKey: Keys.biometricAuthEnabled) == nil {
                return true
            }
            return bool(forKey: Keys.biometricAuthEnabled)
        }
        set {
            set(newValue, forKey: Keys.biometricAuthEnabled)
        }
    }

    /// Check if app requires auth on launch
    var requireAuthOnLaunch: Bool {
        get {
            // Default to true for security
            if object(forKey: Keys.requireAuthOnLaunch) == nil {
                return true
            }
            return bool(forKey: Keys.requireAuthOnLaunch)
        }
        set {
            set(newValue, forKey: Keys.requireAuthOnLaunch)
        }
    }
}
