//
//  TransactionType.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//

import Foundation

/// Represents the type of transaction in the ZKB statement
enum TransactionType: String, Codable, CaseIterable {
    case debit = "Debit"
    case credit = "Credit"

    /// Visual identifier for UI
    var symbol: String {
        switch self {
        case .debit:
            return "−" // Minus sign (Swiss style: proper typography)
        case .credit:
            return "+" // Plus sign
        }
    }

    /// Color identifier key for design system
    var colorKey: String {
        switch self {
        case .debit:
            return "expense" // Maps to Signal Red
        case .credit:
            return "income" // Maps to Emerald Green
        }
    }
}
