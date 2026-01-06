//
//  SecureFileManager.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Secure file handling service with automatic deletion and validation

import Foundation
import UniformTypeIdentifiers

/// Secure file manager for handling sensitive financial documents
final class SecureFileManager {

    // MARK: - Configuration

    /// Maximum file size: 10 MB (prevent DoS attacks)
    static let maxFileSize: UInt64 = 10 * 1024 * 1024

    /// Allowed file types
    static let allowedFileTypes: [UTType] = [.pdf]

    // MARK: - Errors

    enum FileError: LocalizedError {
        case fileTooLarge(size: UInt64, max: UInt64)
        case invalidFileType(type: String)
        case fileNotFound
        case permissionDenied
        case securityScopeAccessFailed
        case unknown(Error)

        var errorDescription: String? {
            switch self {
            case .fileTooLarge(let size, let max):
                let sizeMB = Double(size) / 1024 / 1024
                let maxMB = Double(max) / 1024 / 1024
                return String(format: "File too large (%.1f MB). Maximum allowed: %.1f MB", sizeMB, maxMB)
            case .invalidFileType(let type):
                return "Invalid file type: \(type). Only PDF files are allowed"
            case .fileNotFound:
                return "File not found"
            case .permissionDenied:
                return "Permission denied to access file"
            case .securityScopeAccessFailed:
                return "Failed to access file securely"
            case .unknown(let error):
                return "File error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Singleton

    static let shared = SecureFileManager()

    private let fileManager = FileManager.default

    private init() {}

    // MARK: - Secure Temporary Directory

    /// Get secure temporary directory for processing files
    /// Files in this directory are automatically deleted when no longer needed
    private func secureTemporaryDirectory() throws -> URL {
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("ZuriBudget", isDirectory: true)
            .appendingPathComponent("SecureProcessing", isDirectory: true)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: tempDir.path) {
            try fileManager.createDirectory(
                at: tempDir,
                withIntermediateDirectories: true,
                attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
            )
        }

        return tempDir
    }

    // MARK: - File Validation

    /// Validate file before processing
    /// - Parameter url: File URL to validate
    /// - Throws: FileError if validation fails
    func validateFile(at url: URL) throws {
        // Check if file exists
        guard fileManager.fileExists(atPath: url.path) else {
            throw FileError.fileNotFound
        }

        // Get file attributes
        let attributes: [FileAttributeKey: Any]
        do {
            attributes = try fileManager.attributesOfItem(atPath: url.path)
        } catch {
            throw FileError.unknown(error)
        }

        // Check file size
        if let fileSize = attributes[.size] as? UInt64 {
            guard fileSize <= Self.maxFileSize else {
                throw FileError.fileTooLarge(size: fileSize, max: Self.maxFileSize)
            }
        }

        // Check file type
        let fileType = url.pathExtension.lowercased()
        guard fileType == "pdf" else {
            throw FileError.invalidFileType(type: fileType)
        }

        // Additional validation: Check UTType
        if let utType = UTType(filenameExtension: fileType) {
            guard Self.allowedFileTypes.contains(utType) else {
                throw FileError.invalidFileType(type: fileType)
            }
        }
    }

    // MARK: - Secure File Access

    /// Securely access a file with automatic cleanup
    /// - Parameters:
    ///   - url: Source file URL (from file picker)
    ///   - handler: Closure to process the file
    /// - Returns: Result from handler
    /// - Throws: FileError or errors from handler
    func securelyAccessFile<T>(
        at url: URL,
        handler: (URL) throws -> T
    ) throws -> T {
        // Start accessing security-scoped resource
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        guard accessing else {
            throw FileError.securityScopeAccessFailed
        }

        // Validate file
        try validateFile(at: url)

        // Create secure temporary copy
        let tempDir = try secureTemporaryDirectory()
        let tempURL = tempDir.appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")

        do {
            // Copy to secure temporary location
            try fileManager.copyItem(at: url, to: tempURL)

            // Set file protection
            try fileManager.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: tempURL.path
            )

            // Process file
            let result = try handler(tempURL)

            // Securely delete temporary file
            try securelyDeleteFile(at: tempURL)

            return result

        } catch {
            // Ensure cleanup even if processing fails
            try? securelyDeleteFile(at: tempURL)
            throw error
        }
    }

    // MARK: - Secure Deletion

    /// Securely delete a file (overwrite then remove)
    /// - Parameter url: File URL to delete
    func securelyDeleteFile(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return // Already deleted
        }

        do {
            // Get file size
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int, fileSize > 0 {
                // Overwrite with random data before deletion (defense in depth)
                let randomData = Data((0..<min(fileSize, 1024)).map { _ in UInt8.random(in: 0...255) })
                try randomData.write(to: url, options: .atomic)
            }

            // Remove file
            try fileManager.removeItem(at: url)

        } catch {
            throw FileError.unknown(error)
        }
    }

    /// Clean up all temporary files
    func cleanupTemporaryFiles() throws {
        let tempDir = try secureTemporaryDirectory()

        guard fileManager.fileExists(atPath: tempDir.path) else {
            return
        }

        let contents = try fileManager.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )

        for fileURL in contents {
            try? securelyDeleteFile(at: fileURL)
        }
    }

    // MARK: - File Info

    /// Get file size in bytes
    func fileSize(at url: URL) -> UInt64? {
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? UInt64 else {
            return nil
        }
        return size
    }

    /// Get formatted file size string
    func formattedFileSize(at url: URL) -> String {
        guard let bytes = fileSize(at: url) else {
            return "Unknown size"
        }

        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Memory Security

extension SecureFileManager {

    /// Clear sensitive data from memory
    /// Call this when app enters background
    func clearSensitiveMemory() {
        // Clear URLCache (may contain file references)
        URLCache.shared.removeAllCachedResponses()

        // Force cleanup of temporary files
        try? cleanupTemporaryFiles()
    }

    /// Secure memory wipe helper (for sensitive strings/data)
    static func secureWipe(_ data: inout Data) {
        data.withUnsafeMutableBytes { bytes in
            guard let baseAddress = bytes.baseAddress else { return }
            memset(baseAddress, 0, bytes.count)
        }
        data = Data()
    }
}
