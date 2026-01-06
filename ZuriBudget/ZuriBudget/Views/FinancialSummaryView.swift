//
//  FinancialSummaryView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Swiss-style financial summary cards (Income & Expenses)

import SwiftUI

struct FinancialSummaryView: View {
    let income: String
    let expenses: String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: SwissTypography.baseUnit * 2) {
            // Income Card
            SummaryCard(
                title: "Income",
                amount: income,
                color: .emeraldGreen,
                icon: "arrow.down.circle.fill"
            )

            // Expenses Card
            SummaryCard(
                title: "Expenses",
                amount: expenses,
                color: .signalRed,
                icon: "arrow.up.circle.fill"
            )
        }
    }
}

// MARK: - Summary Card Component

struct SummaryCard: View {
    let title: String
    let amount: String
    let color: Color
    let icon: String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: SwissTypography.baseUnit) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                Spacer()

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .textCase(.uppercase)
                    .kerning(0.5)
            }

            // Amount
            Text(amount)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .kerning(-0.3)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .swissGridPadding(2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .swissCornerRadius()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        FinancialSummaryView(
            income: "CHF 7'500.00",
            expenses: "CHF 2'345.60"
        )

        FinancialSummaryView(
            income: "CHF 0.00",
            expenses: "CHF 0.00"
        )
    }
    .swissGridPadding(2)
    .background(Color(UIColor.systemGroupedBackground))
}
