//
//  Transaction.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//

import Foundation
import SwiftData

/// SwiftData model representing a single financial transaction from ZKB statement
@Model
final class Transaction {
    /// Unique identifier
    var id: UUID

    /// Transaction date (parsed from ZKB statement)
    var date: Date

    /// Raw transaction text from PDF (e.g., "COOP BASEL, KAUFVERTRAG")
    var details: String

    /// Transaction amount in CHF (Swiss Francs)
    /// Uses Decimal for financial precision
    var amount: Decimal

    /// Transaction type (debit or credit)
    var type: TransactionType

    /// Auto-categorized or user-modified category
    var category: Category

    /// Optional user-added notes
    var notes: String?

    /// Timestamp when transaction was imported
    var importedAt: Date

    /// Initializer
    init(
        id: UUID = UUID(),
        date: Date,
        details: String,
        amount: Decimal,
        type: TransactionType,
        category: Category? = nil,
        notes: String? = nil,
        importedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.details = details
        self.amount = amount
        self.type = type
        self.category = category ?? Category.categorize(from: details)
        self.notes = notes
        self.importedAt = importedAt
    }

    /// Formatted amount with CHF symbol (Swiss convention)
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CHF"
        formatter.locale = Locale(identifier: "de_CH") // Swiss German locale
        formatter.currencySymbol = "CHF "
        formatter.currencyGroupingSeparator = "'" // Swiss apostrophe separator
        formatter.currencyDecimalSeparator = "."

        let nsDecimal = amount as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "CHF 0.00"
    }

    /// Display amount with type indicator (+ or -)
    var displayAmount: String {
        let sign = type == .credit ? "+" : "−"
        return "\(sign) \(formattedAmount)"
    }
}

// MARK: - Extensions

extension Transaction {
    /// Sample data for previews
    static var sampleTransactions: [Transaction] {
        [
            Transaction(
                date: Date(),
                details: "COOP Zürich, Kaufvertrag",
                amount: 45.80,
                type: .debit
            ),
            Transaction(
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                details: "SBB Billett Zürich HB",
                amount: 12.40,
                type: .debit
            ),
            Transaction(
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                details: "Lohnzahlung Januar 2026",
                amount: 7500.00,
                type: .credit
            ),
            Transaction(
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                details: "Swisscom AG Rechnung",
                amount: 89.00,
                type: .debit
            ),
            Transaction(
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                details: "Migros Zürich, Einkauf",
                amount: 67.35,
                type: .debit
            )
        ]
    }
}
