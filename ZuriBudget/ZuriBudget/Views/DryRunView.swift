//
//  DryRunView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Preview parsed transactions before saving to database

import SwiftUI

struct DryRunView: View {
    let parseResult: PDFParserService.ParseResult
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                Color.canvasBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SwissTypography.baseUnit * 3) {
                        // Summary header
                        summaryHeader

                        // Parsed transactions
                        VStack(alignment: .leading, spacing: SwissTypography.baseUnit) {
                            Text("Parsed Transactions")
                                .swissHeadline()
                                .foregroundColor(.textPrimary)

                            Text("\(parseResult.transactions.count) transactions found")
                                .swissCaption()

                            LazyVStack(spacing: SwissTypography.baseUnit * 2) {
                                ForEach(parseResult.transactions) { transaction in
                                    TransactionRowView(transaction: transaction)
                                        .swissCard()
                                }
                            }
                        }

                        // Errors (if any)
                        if !parseResult.parseErrors.isEmpty {
                            VStack(alignment: .leading, spacing: SwissTypography.baseUnit) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.signalRed)

                                    Text("Warnings")
                                        .swissHeadline()
                                        .foregroundColor(.textPrimary)
                                }

                                ForEach(parseResult.parseErrors, id: \.self) { error in
                                    Text(error)
                                        .swissBody()
                                        .foregroundColor(.signalRed)
                                        .swissGridPadding(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.signalRed.opacity(0.1))
                                        .swissCornerRadius()
                                }
                            }
                        }

                        // Action buttons
                        actionButtons
                    }
                    .swissGridPadding(2)
                }
            }
            .navigationTitle("Review Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }

    // MARK: - Summary Header

    private var summaryHeader: some View {
        VStack(spacing: SwissTypography.baseUnit * 2) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.emeraldGreen)

            // File info
            VStack(spacing: SwissTypography.baseUnit) {
                Text("PDF Parsed Successfully")
                    .swissHeadline()

                Text(parseResult.fileName)
                    .swissBody()
                    .foregroundColor(.textSecondary)
            }

            // Statistics
            HStack(spacing: SwissTypography.baseUnit * 2) {
                StatCard(
                    label: "Transactions",
                    value: "\(parseResult.transactions.count)",
                    color: .zkbBlue
                )

                StatCard(
                    label: "Credits",
                    value: "\(creditCount)",
                    color: .emeraldGreen
                )

                StatCard(
                    label: "Debits",
                    value: "\(debitCount)",
                    color: .signalRed
                )
            }
        }
        .swissGridPadding(2)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .swissCornerRadius()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: SwissTypography.baseUnit * 2) {
            // Confirm button
            Button {
                onConfirm()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Import \(parseResult.transactions.count) Transactions")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .swissGridPadding(2)
                .foregroundColor(.white)
                .background(Color.emeraldGreen)
                .swissCornerRadius()
            }

            // Cancel button
            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .swissGridPadding(2)
                    .foregroundColor(.signalRed)
                    .background(Color.signalRed.opacity(0.1))
                    .swissCornerRadius()
            }

            // Security notice
            Text("PDF will be automatically deleted after import")
                .swissCaption()
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Computed Properties

    private var creditCount: Int {
        parseResult.transactions.filter { $0.type == .credit }.count
    }

    private var debitCount: Int {
        parseResult.transactions.filter { $0.type == .debit }.count
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: SwissTypography.baseUnit / 2) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .kerning(-0.3)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
                .textCase(.uppercase)
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity)
        .swissGridPadding(1)
    }
}

// MARK: - Preview

#Preview {
    DryRunView(
        parseResult: PDFParserService.sampleParseResult,
        onConfirm: {},
        onCancel: {}
    )
}
