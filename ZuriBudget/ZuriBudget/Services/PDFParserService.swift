//
//  PDFParserService.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//

import Foundation
import PDFKit

/// Service for parsing ZKB (Zürcher Kantonalbank) monthly statement PDFs
/// Handles Swiss-specific number formatting and date patterns
final class PDFParserService {

    // MARK: - Parser Result

    struct ParseResult {
        let transactions: [Transaction]
        let rawLines: [String] // For debugging and dry-run verification
        let parseErrors: [String]
        let fileName: String
    }

    // MARK: - Swiss Formatting Patterns

    /// Date pattern: dd.mm.yyyy or dd.mm.yy
    /// Examples: 15.01.2026, 15.01.26
    private static let datePattern = #"(\d{1,2}\.\d{1,2}\.(?:\d{4}|\d{2}))"#

    /// Amount pattern with Swiss formatting
    /// Handles: CHF 1'200.50, -50.00, 1'234.56, 123.45
    /// Swiss convention: apostrophe (') as thousand separator, period (.) or comma (,) as decimal
    private static let amountPattern = #"(?:CHF\s*)?(-?)(\d{1,3}(?:[']\d{3})*(?:[.,]\d{2})?)"#

    /// Common noise patterns to filter out
    private static let noisePatterns = [
        #"^Page\s+\d+"#,
        #"^Seite\s+\d+"#,
        #"^IBAN"#,
        #"^Saldo"#,
        #"^Balance"#,
        #"^Kontostand"#,
        #"^Zürcher\s+Kantonalbank"#,
        #"^ZKB"#,
        #"^Kontoauszug"#,
        #"^Account\s+Statement"#,
        #"^\s*$"#, // Empty lines
        #"^-{3,}"#, // Separator lines
        #"^={3,}"#
    ]

    // MARK: - Public Methods

    /// Securely parse a ZKB PDF statement with automatic file deletion
    /// - Parameter url: URL to the PDF file (from file picker)
    /// - Returns: ParseResult containing transactions and metadata
    /// - Throws: SecureFileManager.FileError if validation or access fails
    static func securelyParseZKBStatement(url: URL) throws -> ParseResult {
        // Use SecureFileManager for secure access and automatic deletion
        return try SecureFileManager.shared.securelyAccessFile(at: url) { secureURL in
            // Parse the securely accessed file
            return parseZKBStatement(url: secureURL)
        }
    }

    /// Parse a ZKB PDF statement (internal method)
    /// - Parameter url: URL to the PDF file
    /// - Returns: ParseResult containing transactions and metadata
    static func parseZKBStatement(url: URL) -> ParseResult {
        var transactions: [Transaction] = []
        var rawLines: [String] = []
        var parseErrors: [String] = []
        let fileName = url.lastPathComponent

        // Validate file size (additional security check)
        if let fileSize = SecureFileManager.shared.fileSize(at: url),
           fileSize > SecureFileManager.maxFileSize {
            parseErrors.append("File too large: \(SecureFileManager.shared.formattedFileSize(at: url))")
            return ParseResult(
                transactions: [],
                rawLines: [],
                parseErrors: parseErrors,
                fileName: fileName
            )
        }

        // Load PDF
        guard let pdfDocument = PDFDocument(url: url) else {
            parseErrors.append("Failed to load PDF document")
            return ParseResult(
                transactions: [],
                rawLines: [],
                parseErrors: parseErrors,
                fileName: fileName
            )
        }

        // Additional security: Limit page count to prevent DoS
        let maxPages = 100
        guard pdfDocument.pageCount <= maxPages else {
            parseErrors.append("PDF has too many pages (\(pdfDocument.pageCount)). Maximum: \(maxPages)")
            return ParseResult(
                transactions: [],
                rawLines: [],
                parseErrors: parseErrors,
                fileName: fileName
            )
        }

        // Extract text from all pages
        let pageCount = pdfDocument.pageCount
        var fullText = ""

        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex),
                  let pageContent = page.string else {
                continue
            }
            fullText += pageContent + "\n"
        }

        // Split into lines and process
        let lines = fullText.components(separatedBy: .newlines)
        rawLines = lines

        for (index, line) in lines.enumerated() {
            // Skip noise
            if shouldSkipLine(line) {
                continue
            }

            // Attempt to parse transaction
            if let transaction = parseTransactionLine(line, lineNumber: index + 1) {
                transactions.append(transaction)
            } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                // Log non-empty lines that couldn't be parsed (for debugging)
                // Not added as error to avoid noise
            }
        }

        if transactions.isEmpty {
            parseErrors.append("No transactions found in PDF. Check if format matches ZKB statement.")
        }

        return ParseResult(
            transactions: transactions,
            rawLines: rawLines,
            parseErrors: parseErrors,
            fileName: fileName
        )
    }

    // MARK: - Private Helpers

    /// Check if a line should be skipped (headers, footers, etc.)
    private static func shouldSkipLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Check against noise patterns
        for pattern in noisePatterns {
            if trimmed.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }

        return false
    }

    /// Parse a single transaction line
    /// Expected format: "15.01.2026 COOP Zürich, Kaufvertrag CHF 45.80"
    /// Or: "15.01.2026 Salary Payment -7500.00"
    private static func parseTransactionLine(_ line: String, lineNumber: Int) -> Transaction? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Must contain a date
        guard let dateMatch = extractDate(from: trimmed) else {
            return nil
        }

        // Must contain an amount
        guard let (amount, isNegative) = extractAmount(from: trimmed) else {
            return nil
        }

        // Extract details (everything between date and amount)
        let details = extractDetails(from: trimmed, dateRange: dateMatch.range)

        // Determine transaction type
        // In ZKB statements: negative amounts = debits (expenses), positive = credits (income)
        let type: TransactionType = isNegative ? .debit : .credit

        return Transaction(
            date: dateMatch.date,
            details: details,
            amount: amount,
            type: type
        )
    }

    /// Extract date from line
    private static func extractDate(from line: String) -> (date: Date, range: NSRange)? {
        guard let regex = try? NSRegularExpression(pattern: datePattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }

        let dateString = (line as NSString).substring(with: match.range)
        let date = parseSwissDate(dateString)

        return date.map { ($0, match.range) }
    }

    /// Parse Swiss date format (dd.mm.yyyy or dd.mm.yy)
    private static func parseSwissDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_CH")

        // Try full year first
        formatter.dateFormat = "dd.MM.yyyy"
        if let date = formatter.date(from: dateString) {
            return date
        }

        // Try short year
        formatter.dateFormat = "dd.MM.yy"
        return formatter.date(from: dateString)
    }

    /// Extract amount and sign from line
    /// Returns (amount, isNegative)
    private static func extractAmount(from line: String) -> (Decimal, Bool)? {
        guard let regex = try? NSRegularExpression(pattern: amountPattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }

        // Extract sign (group 1)
        let signRange = match.range(at: 1)
        let isNegative = signRange.length > 0

        // Extract amount (group 2)
        let amountRange = match.range(at: 2)
        guard amountRange.location != NSNotFound else {
            return nil
        }

        var amountString = (line as NSString).substring(with: amountRange)

        // Normalize Swiss formatting
        // Remove apostrophe thousand separators
        amountString = amountString.replacingOccurrences(of: "'", with: "")

        // Replace comma decimal separator with period (if used)
        amountString = amountString.replacingOccurrences(of: ",", with: ".")

        guard let decimal = Decimal(string: amountString) else {
            return nil
        }

        return (decimal, isNegative)
    }

    /// Extract transaction details (text between date and amount)
    private static func extractDetails(from line: String, dateRange: NSRange) -> String {
        // Start after the date
        let startIndex = line.index(line.startIndex, offsetBy: dateRange.location + dateRange.length)

        // Find the last occurrence of a number pattern (the amount)
        var detailsEndIndex = line.endIndex

        if let amountRegex = try? NSRegularExpression(pattern: amountPattern),
           let lastMatch = amountRegex.matches(in: line, range: NSRange(line.startIndex..., in: line)).last {
            detailsEndIndex = line.index(line.startIndex, offsetBy: lastMatch.range.location)
        }

        let details = String(line[startIndex..<detailsEndIndex])
            .trimmingCharacters(in: .whitespaces)

        return details.isEmpty ? "Unknown Transaction" : details
    }

    // MARK: - Validation Helpers

    /// Securely validate if a file appears to be a ZKB statement
    /// - Parameter url: URL to the PDF file (from file picker)
    /// - Returns: Validation result
    static func securelyValidateZKBStatement(url: URL) -> (isValid: Bool, reason: String) {
        do {
            // First validate with SecureFileManager
            try SecureFileManager.shared.validateFile(at: url)

            // Then validate ZKB-specific content
            return try SecureFileManager.shared.securelyAccessFile(at: url) { secureURL in
                return validateZKBStatement(url: secureURL)
            }
        } catch let error as SecureFileManager.FileError {
            return (false, error.localizedDescription)
        } catch {
            return (false, "Validation error: \(error.localizedDescription)")
        }
    }

    /// Validate if a file appears to be a ZKB statement (internal method)
    static func validateZKBStatement(url: URL) -> (isValid: Bool, reason: String) {
        guard let pdfDocument = PDFDocument(url: url) else {
            return (false, "Invalid PDF file")
        }

        guard pdfDocument.pageCount > 0 else {
            return (false, "PDF has no pages")
        }

        // Security: Check page count limit
        guard pdfDocument.pageCount <= 100 else {
            return (false, "PDF has too many pages (potential security risk)")
        }

        // Check first page for ZKB indicators
        guard let firstPage = pdfDocument.page(at: 0),
              let content = firstPage.string?.lowercased() else {
            return (false, "Cannot read PDF content")
        }

        // Security: Limit content size to prevent memory issues
        guard content.count < 1_000_000 else {
            return (false, "PDF content too large")
        }

        // Look for ZKB-specific text
        let zkbIndicators = ["zürcher kantonalbank", "zkb", "kontoauszug"]
        let hasZKBIndicator = zkbIndicators.contains { content.contains($0) }

        if !hasZKBIndicator {
            return (false, "PDF does not appear to be a ZKB statement")
        }

        return (true, "Valid ZKB statement")
    }
}

// MARK: - Preview Helper

extension PDFParserService {
    /// Generate a sample parse result for previews
    static var sampleParseResult: ParseResult {
        ParseResult(
            transactions: Transaction.sampleTransactions,
            rawLines: [
                "Zürcher Kantonalbank",
                "Kontoauszug Januar 2026",
                "15.01.2026 COOP Zürich, Kaufvertrag CHF 45.80",
                "14.01.2026 SBB Billett Zürich HB CHF 12.40",
                "13.01.2026 Lohnzahlung Januar 2026 -7'500.00",
                "Saldo: CHF 8'234.56"
            ],
            parseErrors: [],
            fileName: "ZKB_Statement_January_2026.pdf"
        )
    }
}
