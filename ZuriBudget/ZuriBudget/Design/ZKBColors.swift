//
//  ZKBColors.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Swiss International Style color system for ZKB brand identity

import SwiftUI

/// ZKB brand colors following Swiss design principles
/// High contrast, functional color usage, minimal palette
extension Color {

    // MARK: - Primary Brand Colors

    /// ZKB Blue - Primary brand color
    /// Use for: Headers, primary actions, brand elements
    static let zkbBlue = Color(hex: "0066B2")

    /// Zürich Blue - Secondary/Highlight
    /// Use for: Interactive elements, selected states, accents
    static let zurichBlue = Color(hex: "268BCC")

    // MARK: - Functional Colors

    /// Signal Red - Expenses/Debits
    /// Use for: Negative amounts, expenses, critical actions
    static let signalRed = Color(hex: "FF3B30")

    /// Emerald Green - Income/Credits
    /// Use for: Positive amounts, income, success states
    static let emeraldGreen = Color(hex: "34C759")

    // MARK: - Neutrals

    /// Pure White - Light mode background
    static let canvasLight = Color(hex: "FFFFFF")

    /// Deep Slate - Dark mode background
    static let canvasDark = Color(hex: "1C1C1E")

    /// Swiss Grid Gray - Subtle dividers and borders
    static let gridGray = Color(hex: "E5E5E5")

    /// Text Primary - High contrast text
    static let textPrimary = Color.primary

    /// Text Secondary - Reduced emphasis text
    static let textSecondary = Color.secondary

    // MARK: - Semantic Colors

    /// Dynamic color for income/credit
    static func incomeColor(for colorScheme: ColorScheme) -> Color {
        emeraldGreen
    }

    /// Dynamic color for expenses/debit
    static func expenseColor(for colorScheme: ColorScheme) -> Color {
        signalRed
    }

    /// Dynamic canvas background
    static func canvasBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? canvasDark : canvasLight
    }

    // MARK: - Hex Initializer

    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

// MARK: - Swiss Design System Modifiers

extension View {

    /// Apply Swiss grid system padding
    /// Standard spacing: 8pt base unit
    func swissGridPadding(_ multiplier: CGFloat = 2) -> some View {
        self.padding(8 * multiplier)
    }

    /// Apply minimal corner radius (Swiss style: sharp or very subtle)
    func swissCornerRadius() -> some View {
        self.cornerRadius(6)
    }

    /// Apply Swiss typography hierarchy
    func swissTitle() -> some View {
        self
            .font(.system(size: 34, weight: .bold, design: .default))
            .kerning(-0.5) // Tight tracking, Swiss style
    }

    func swissHeadline() -> some View {
        self
            .font(.system(size: 24, weight: .bold, design: .default))
            .kerning(-0.3)
    }

    func swissBody() -> some View {
        self
            .font(.system(size: 17, weight: .regular, design: .default))
    }

    func swissCaption() -> some View {
        self
            .font(.system(size: 13, weight: .regular, design: .default))
            .foregroundColor(.textSecondary)
    }

    /// Apply Swiss-style card background
    func swissCard() -> some View {
        self
            .background(Color(UIColor.secondarySystemBackground))
            .swissCornerRadius()
    }
}

// MARK: - Typography Constants

enum SwissTypography {
    static let baseUnit: CGFloat = 8

    enum FontSize {
        static let largeTitle: CGFloat = 34
        static let title1: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption: CGFloat = 12
    }

    enum FontWeight {
        static let bold: Font.Weight = .bold
        static let semibold: Font.Weight = .semibold
        static let regular: Font.Weight = .regular
        static let light: Font.Weight = .light
    }

    enum Kerning {
        static let tight: CGFloat = -0.5
        static let normal: CGFloat = 0
        static let loose: CGFloat = 0.5
    }
}
