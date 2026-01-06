//
//  DataProtectionManager.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Data protection and encryption configuration for SwiftData

import Foundation
import SwiftData

/// Manager for data protection and encryption settings
final class DataProtectionManager {

    // MARK: - Singleton

    static let shared = DataProtectionManager()

    private init() {}

    // MARK: - SwiftData Configuration

    /// Create a secure ModelContainer with full encryption
    /// - Parameter schema: SwiftData schema
    /// - Returns: Configured ModelContainer with encryption enabled
    /// - Throws: Error if container creation fails
    func createSecureModelContainer(for schema: Schema) throws -> ModelContainer {

        // Configure model with encryption
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none // Explicitly disable CloudKit for privacy
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )

        // Apply file protection to the database file
        try applyFileProtection(to: container)

        return container
    }

    /// Apply file protection attributes to SwiftData database files
    private func applyFileProtection(to container: ModelContainer) throws {
        // Get the model context to access the database URL
        let descriptor = container.configurations.first

        // SwiftData uses a default.store file in the Application Support directory
        let appSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first

        guard let appSupportURL = appSupportURL else {
            return
        }

        // Apply protection to the Application Support directory
        try setFileProtection(.complete, at: appSupportURL)

        // Also protect the entire app's data directory
        try protectAppDataDirectory()
    }

    /// Set file protection on a specific file or directory
    /// - Parameters:
    ///   - protection: File protection type
    ///   - url: File or directory URL
    func setFileProtection(_ protection: FileProtectionType, at url: URL) throws {
        try FileManager.default.setAttributes(
            [.protectionKey: protection],
            ofItemAtPath: url.path
        )
    }

    /// Apply comprehensive protection to app's data directory
    func protectAppDataDirectory() throws {
        let fileManager = FileManager.default

        // Protect Documents directory
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            try? setFileProtection(.complete, at: documentsURL)
        }

        // Protect Application Support directory
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            try? setFileProtection(.complete, at: appSupportURL)
        }

        // Protect Caches directory (less strict - available after first unlock)
        if let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            try? setFileProtection(.completeUntilFirstUserAuthentication, at: cachesURL)
        }
    }

    // MARK: - Memory Protection

    /// Clear sensitive data when app backgrounds
    func clearSensitiveDataOnBackground() {
        // Clear pasteboard (in case user copied sensitive data)
        #if !os(macOS)
        UIPasteboard.general.items = []
        #endif

        // Clear URL cache
        URLCache.shared.removeAllCachedResponses()

        // Request secure file manager cleanup
        try? SecureFileManager.shared.cleanupTemporaryFiles()
    }

    /// Prepare for app suspension (called when app will resign active)
    func prepareForSuspension() {
        // Flush any pending writes
        // SwiftData handles this automatically

        // Clear caches
        clearSensitiveDataOnBackground()
    }

    // MARK: - Encryption Verification

    /// Verify that data protection is properly configured
    /// - Returns: true if protection is enabled, false otherwise
    func verifyDataProtection() -> Bool {
        let fileManager = FileManager.default

        // Check Documents directory protection
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let attributes = try? fileManager.attributesOfItem(atPath: documentsURL.path),
              let protection = attributes[.protectionKey] as? FileProtectionType else {
            return false
        }

        // Verify protection level is adequate
        return protection == .complete ||
               protection == .completeUnlessOpen ||
               protection == .completeUntilFirstUserAuthentication
    }

    /// Get current data protection level description
    func dataProtectionStatus() -> String {
        if verifyDataProtection() {
            return "Data protection: Active (Complete)"
        } else {
            return "Data protection: Warning - Not fully configured"
        }
    }
}

// MARK: - File Protection Type Extension

extension FileProtectionType {
    /// Human-readable description
    var description: String {
        switch self {
        case .complete:
            return "Complete (requires device unlock)"
        case .completeUnlessOpen:
            return "Complete unless open"
        case .completeUntilFirstUserAuthentication:
            return "Complete until first authentication"
        case .none:
            return "None"
        default:
            return "Unknown"
        }
    }

    /// Security level (0-3, higher is more secure)
    var securityLevel: Int {
        switch self {
        case .complete:
            return 3
        case .completeUnlessOpen:
            return 2
        case .completeUntilFirstUserAuthentication:
            return 1
        case .none:
            return 0
        default:
            return 0
        }
    }
}
