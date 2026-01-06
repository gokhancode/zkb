//
//  ZuriBudgetApp.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Main app entry point with SwiftData configuration and security features

import SwiftUI
import SwiftData

@main
struct ZuriBudgetApp: App {

    // MARK: - App State

    @Environment(\.scenePhase) private var scenePhase
    @State private var isAuthenticated = false
    @State private var showAuthError = false
    @State private var authError: String?

    // MARK: - SwiftData Configuration

    /// SwiftData model container with encryption and data protection
    var modelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self
        ])

        do {
            // Use DataProtectionManager for secure container creation
            return try DataProtectionManager.shared.createSecureModelContainer(for: schema)
        } catch {
            fatalError("Could not create secure ModelContainer: \(error)")
        }
    }()

    // MARK: - Initialization

    init() {
        // Apply data protection on app launch
        do {
            try DataProtectionManager.shared.protectAppDataDirectory()
        } catch {
            print("Warning: Could not apply full data protection: \(error)")
        }
    }

    // MARK: - App Body

    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    // Authenticated: Show main content
                    ContentView()
                        .modelContainer(modelContainer)
                        .preferredColorScheme(nil) // Respect system setting
                } else {
                    // Not authenticated: Show lock screen
                    AuthenticationView(
                        isAuthenticated: $isAuthenticated,
                        showError: $showAuthError,
                        errorMessage: $authError
                    )
                }
            }
            .alert("Authentication Error", isPresented: $showAuthError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = authError {
                    Text(error)
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }

    // MARK: - Scene Phase Handling

    /// Handle app lifecycle changes for security
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // App became active - authenticate if required
            if UserDefaults.standard.requireAuthOnLaunch && !isAuthenticated {
                Task {
                    await authenticate()
                }
            }

        case .inactive:
            // App becoming inactive - prepare for suspension
            DataProtectionManager.shared.prepareForSuspension()

        case .background:
            // App entered background - clear sensitive data and lock
            DataProtectionManager.shared.clearSensitiveDataOnBackground()

            // Require re-authentication when returning
            if UserDefaults.standard.requireAuthOnLaunch {
                isAuthenticated = false
            }

        @unknown default:
            break
        }
    }

    // MARK: - Authentication

    /// Authenticate user with biometrics or passcode
    private func authenticate() async {
        // Skip if already authenticated
        guard !isAuthenticated else { return }

        // Skip if user disabled auth (not recommended, but supported)
        guard UserDefaults.standard.requireAuthOnLaunch else {
            isAuthenticated = true
            return
        }

        do {
            // Try biometric authentication first
            try await BiometricAuthService.shared.authenticate()
            isAuthenticated = true
        } catch let error as BiometricAuthService.AuthError {
            // Handle specific auth errors
            switch error {
            case .userCancelled:
                authError = "Authentication cancelled"
                showAuthError = true

            case .biometricNotAvailable, .biometricNotEnrolled:
                // Fall back to passcode if biometrics unavailable
                do {
                    try await BiometricAuthService.shared.authenticateWithPasscode()
                    isAuthenticated = true
                } catch {
                    authError = error.localizedDescription
                    showAuthError = true
                }

            default:
                authError = error.localizedDescription
                showAuthError = true
            }
        } catch {
            authError = "Authentication failed: \(error.localizedDescription)"
            showAuthError = true
        }
    }
}

// MARK: - Authentication View

/// Lock screen with biometric authentication
struct AuthenticationView: View {
    @Binding var isAuthenticated: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Swiss-style background
            Color.canvasBackground(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: SwissTypography.baseUnit * 4) {
                Spacer()

                // App branding
                VStack(spacing: SwissTypography.baseUnit * 2) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.zkbBlue)

                    Text("ZüriBudget")
                        .swissTitle()
                        .foregroundColor(.zkbBlue)

                    Text("Secure Finance Tracker")
                        .swissCaption()
                }

                Spacer()

                // Authentication prompt
                VStack(spacing: SwissTypography.baseUnit * 2) {
                    let biometricType = BiometricAuthService.shared.biometricTypeDescription()

                    Text("Unlock with \(biometricType)")
                        .swissHeadline()

                    Button {
                        Task {
                            await authenticate()
                        }
                    } label: {
                        HStack {
                            Image(systemName: biometricIcon)
                                .font(.system(size: 20))

                            Text("Authenticate")
                                .swissBody()
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.zkbBlue)
                        .swissCornerRadius()
                    }
                    .swissGridPadding(2)
                }

                Spacer()

                // Privacy notice
                Text("Your data is protected with encryption")
                    .swissCaption()
                    .multilineTextAlignment(.center)
                    .swissGridPadding(2)
            }
            .swissGridPadding(2)
        }
    }

    private var biometricIcon: String {
        switch BiometricAuthService.shared.biometricType() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.fill"
        }
    }

    private func authenticate() async {
        do {
            try await BiometricAuthService.shared.authenticate()
            isAuthenticated = true
        } catch let error as BiometricAuthService.AuthError {
            switch error {
            case .biometricNotAvailable, .biometricNotEnrolled:
                // Fall back to passcode
                do {
                    try await BiometricAuthService.shared.authenticateWithPasscode()
                    isAuthenticated = true
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }

            case .userCancelled:
                // Don't show error for cancellation
                break

            default:
                errorMessage = error.localizedDescription
                showError = true
            }
        } catch {
            errorMessage = "Authentication failed: \(error.localizedDescription)"
            showError = true
        }
    }
}

// MARK: - Content View (Temporary Entry)

/// Temporary content view with security status
/// Will be replaced with HomeView in next phase
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]

    var body: some View {
        NavigationStack {
            ZStack {
                // Swiss-style background
                Color.canvasBackground(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: SwissTypography.baseUnit * 3) {
                    // App branding
                    VStack(spacing: SwissTypography.baseUnit) {
                        Text("ZüriBudget")
                            .swissTitle()
                            .foregroundColor(.zkbBlue)

                        Text("Finance Tracker for ZKB Users")
                            .swissCaption()
                    }
                    .swissGridPadding(3)

                    // Status indicator
                    VStack(spacing: SwissTypography.baseUnit * 2) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.emeraldGreen)

                        Text("Security Active")
                            .swissHeadline()

                        Text("\(transactions.count) transactions loaded")
                            .swissBody()
                            .foregroundColor(.textSecondary)
                    }

                    // System info
                    VStack(alignment: .leading, spacing: SwissTypography.baseUnit) {
                        InfoRow(label: "SwiftData", value: "Encrypted")
                        InfoRow(label: "Authentication", value: BiometricAuthService.shared.biometricTypeDescription())
                        InfoRow(label: "File Protection", value: DataProtectionManager.shared.verifyDataProtection() ? "Active" : "Warning")
                        InfoRow(label: "PDF Auto-Delete", value: "Enabled")
                        InfoRow(label: "Categories", value: "\(Category.allCases.count)")
                    }
                    .swissCard()
                    .swissGridPadding(2)

                    Spacer()

                    // Security notice
                    Text("🔒 Your data never leaves this device")
                        .swissCaption()
                        .foregroundColor(.textSecondary)
                }
                .swissGridPadding(2)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Views

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .swissBody()
                .foregroundColor(.textSecondary)

            Spacer()

            Text(value)
                .swissBody()
                .foregroundColor(.zkbBlue)
                .fontWeight(.semibold)
        }
        .swissGridPadding(1)
    }
}

// MARK: - Previews

#Preview("Authenticated") {
    ContentView()
        .modelContainer(for: Transaction.self, inMemory: true)
}

#Preview("Lock Screen") {
    AuthenticationView(
        isAuthenticated: .constant(false),
        showError: .constant(false),
        errorMessage: .constant(nil)
    )
}
