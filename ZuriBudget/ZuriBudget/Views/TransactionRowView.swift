//
//  TransactionRowView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Swiss-style transaction row component

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: SwissTypography.baseUnit * 2) {
            // Category icon
            Image(systemName: transaction.category.icon)
                .font(.system(size: 24))
                .foregroundColor(.zkbBlue)
                .frame(width: 40, height: 40)

            // Transaction details
            VStack(alignment: .leading, spacing: SwissTypography.baseUnit / 2) {
                Text(transaction.details)
                    .swissBody()
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)

                HStack(spacing: SwissTypography.baseUnit) {
                    // Category badge
                    Text(transaction.category.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.zkbBlue)
                        .padding(.horizontal, SwissTypography.baseUnit)
                        .padding(.vertical, SwissTypography.baseUnit / 2)
                        .background(Color.zkbBlue.opacity(0.1))
                        .cornerRadius(4)

                    // Date
                    Text(transaction.date, format: .dateTime.day().month().year())
                        .swissCaption()
                }
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: SwissTypography.baseUnit / 2) {
                Text(transaction.formattedAmount)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(amountColor)

                Text(transaction.type.symbol)
                    .font(.system(size: 14))
                    .foregroundColor(amountColor)
            }
        }
        .swissGridPadding(2)
    }

    private var amountColor: Color {
        transaction.type == .credit ? .emeraldGreen : .signalRed
    }
}

// MARK: - Preview

#Preview("Credit Transaction") {
    TransactionRowView(
        transaction: Transaction(
            date: Date(),
            details: "Lohnzahlung Januar 2026",
            amount: 7500.00,
            type: .credit
        )
    )
    .swissCard()
    .swissGridPadding(2)
}

#Preview("Debit Transaction") {
    TransactionRowView(
        transaction: Transaction(
            date: Date(),
            details: "COOP Zürich, Kaufvertrag",
            amount: 45.80,
            type: .debit
        )
    )
    .swissCard()
    .swissGridPadding(2)
}
