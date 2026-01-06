//
//  Category.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//

import Foundation

/// Transaction categories with Swiss/ZKB-specific keyword matching
enum Category: String, Codable, CaseIterable {
    case groceries = "Groceries"
    case transport = "Transport"
    case rent = "Rent"
    case utilities = "Utilities"
    case healthcare = "Healthcare"
    case dining = "Dining"
    case shopping = "Shopping"
    case insurance = "Insurance"
    case salary = "Salary"
    case entertainment = "Entertainment"
    case education = "Education"
    case savings = "Savings"
    case other = "Other"

    /// Icon identifier for UI
    var icon: String {
        switch self {
        case .groceries:
            return "cart.fill"
        case .transport:
            return "tram.fill"
        case .rent:
            return "house.fill"
        case .utilities:
            return "bolt.fill"
        case .healthcare:
            return "cross.case.fill"
        case .dining:
            return "fork.knife"
        case .shopping:
            return "bag.fill"
        case .insurance:
            return "shield.fill"
        case .salary:
            return "banknote.fill"
        case .entertainment:
            return "theatermasks.fill"
        case .education:
            return "book.fill"
        case .savings:
            return "chart.line.uptrend.xyaxis"
        case .other:
            return "tag.fill"
        }
    }

    /// Auto-categorize based on transaction details
    /// Handles Swiss German, German, and English keywords
    static func categorize(from details: String) -> Category {
        let normalized = details.lowercased()

        // Groceries: Coop, Migros, Denner, Aldi, Lidl
        if normalized.contains("coop") ||
           normalized.contains("migros") ||
           normalized.contains("denner") ||
           normalized.contains("aldi") ||
           normalized.contains("lidl") ||
           normalized.contains("spar") ||
           normalized.contains("volg") {
            return .groceries
        }

        // Transport: SBB, ZVV, VBZ, Mobility, Uber
        if normalized.contains("sbb") ||
           normalized.contains("zvv") ||
           normalized.contains("vbz") ||
           normalized.contains("mobility") ||
           normalized.contains("uber") ||
           normalized.contains("taxi") ||
           normalized.contains("publibike") ||
           normalized.contains("lime") {
            return .transport
        }

        // Rent: Miete, Rent, Wohnung
        if normalized.contains("miete") ||
           normalized.contains("rent") ||
           normalized.contains("wohnung") ||
           normalized.contains("immobilien") {
            return .rent
        }

        // Utilities: Elektrizität, Gas, Wasser, EWZ, Swisscom, Salt, Sunrise
        if normalized.contains("ewz") ||
           normalized.contains("swisscom") ||
           normalized.contains("salt") ||
           normalized.contains("sunrise") ||
           normalized.contains("elektrizität") ||
           normalized.contains("strom") ||
           normalized.contains("gas") ||
           normalized.contains("wasser") ||
           normalized.contains("utilities") {
            return .utilities
        }

        // Healthcare: Krankenkasse, Apotheke, Arzt, Zahnarzt
        if normalized.contains("krankenkasse") ||
           normalized.contains("css") ||
           normalized.contains("helsana") ||
           normalized.contains("sanitas") ||
           normalized.contains("apotheke") ||
           normalized.contains("pharmacy") ||
           normalized.contains("arzt") ||
           normalized.contains("zahnarzt") ||
           normalized.contains("spital") ||
           normalized.contains("hospital") {
            return .healthcare
        }

        // Dining: Restaurant, Café, Starbucks, McDonald's
        if normalized.contains("restaurant") ||
           normalized.contains("café") ||
           normalized.contains("coffee") ||
           normalized.contains("starbucks") ||
           normalized.contains("mcdonald") ||
           normalized.contains("burger king") ||
           normalized.contains("pizzeria") ||
           normalized.contains("bar") {
            return .dining
        }

        // Shopping: H&M, Zara, Manor, Globus
        if normalized.contains("h&m") ||
           normalized.contains("zara") ||
           normalized.contains("manor") ||
           normalized.contains("globus") ||
           normalized.contains("jelmoli") ||
           normalized.contains("amazon") ||
           normalized.contains("digitec") ||
           normalized.contains("galaxus") {
            return .shopping
        }

        // Insurance: Versicherung, Allianz, Zurich Insurance, AXA
        if normalized.contains("versicherung") ||
           normalized.contains("insurance") ||
           normalized.contains("allianz") ||
           normalized.contains("axa") ||
           normalized.contains("zurich insurance") ||
           normalized.contains("helvetia") {
            return .insurance
        }

        // Salary: Lohn, Gehalt, Salary
        if normalized.contains("lohn") ||
           normalized.contains("gehalt") ||
           normalized.contains("salary") ||
           normalized.contains("lohnzahlung") {
            return .salary
        }

        // Entertainment: Kino, Cinema, Netflix, Spotify
        if normalized.contains("kino") ||
           normalized.contains("cinema") ||
           normalized.contains("netflix") ||
           normalized.contains("spotify") ||
           normalized.contains("apple music") ||
           normalized.contains("theater") ||
           normalized.contains("konzert") {
            return .entertainment
        }

        // Education: Universität, ETH, Uni, School
        if normalized.contains("eth") ||
           normalized.contains("universität") ||
           normalized.contains("university") ||
           normalized.contains("uzh") ||
           normalized.contains("schule") ||
           normalized.contains("school") {
            return .education
        }

        // Savings: Sparkonto, Savings Account
        if normalized.contains("sparkonto") ||
           normalized.contains("savings") ||
           normalized.contains("3a") ||
           normalized.contains("vorsorgekonto") {
            return .savings
        }

        return .other
    }
}
