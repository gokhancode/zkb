//
//  HomeViewModel.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  ViewModel for HomeView - Manages transaction data and statistics

import Foundation
import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {

    // MARK: - Properties

    var transactions: [Transaction] = []
    var isImporting = false
    var showDryRun = false
    var dryRunResult: PDFParserService.ParseResult?
    var errorMessage: String?
    var showError = false

    // MARK: - Computed Properties

    /// Total balance (income - expenses)
    var balance: Decimal {
        transactions.reduce(0) { total, transaction in
            switch transaction.type {
            case .credit:
                return total + transaction.amount
            case .debit:
                return total - transaction.amount
            }
        }
    }

    /// Total income
    var totalIncome: Decimal {
        transactions
            .filter { $0.type == .credit }
            .reduce(0) { $0 + $1.amount }
    }

    /// Total expenses
    var totalExpenses: Decimal {
        transactions
            .filter { $0.type == .debit }
            .reduce(0) { $0 + $1.amount }
    }

    /// Recent transactions (last 10)
    var recentTransactions: [Transaction] {
        Array(transactions
            .sorted { $0.date > $1.date }
            .prefix(10))
    }

    /// Transactions grouped by category
    var transactionsByCategory: [Category: [Transaction]] {
        Dictionary(grouping: transactions) { $0.category }
    }

    /// Formatted balance
    var formattedBalance: String {
        formatCurrency(balance)
    }

    /// Formatted income
    var formattedIncome: String {
        formatCurrency(totalIncome)
    }

    /// Formatted expenses
    var formattedExpenses: String {
        formatCurrency(totalExpenses)
    }

    // MARK: - PDF Import

    /// Handle PDF file selection
    func handlePDFSelection(url: URL) {
        isImporting = true

        // Parse PDF securely on background thread
        Task {
            do {
                let result = try PDFParserService.securelyParseZKBStatement(url: url)

                await MainActor.run {
                    if result.parseErrors.isEmpty && !result.transactions.isEmpty {
                        // Show dry-run view for user verification
                        self.dryRunResult = result
                        self.showDryRun = true
                    } else {
                        // Show errors
                        self.errorMessage = result.parseErrors.joined(separator: "\n")
                        self.showError = true
                    }
                    self.isImporting = false
                }
            } catch let error as SecureFileManager.FileError {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isImporting = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to parse PDF: \(error.localizedDescription)"
                    self.showError = true
                    self.isImporting = false
                }
            }
        }
    }

    /// Confirm and save transactions from dry-run
    func confirmTransactions(modelContext: ModelContext) {
        guard let result = dryRunResult else { return }

        // Save transactions to SwiftData
        for transaction in result.transactions {
            modelContext.insert(transaction)
        }

        // Clear dry-run state
        dryRunResult = nil
        showDryRun = false
    }

    /// Cancel dry-run without saving
    func cancelDryRun() {
        dryRunResult = nil
        showDryRun = false
    }

    // MARK: - Transaction Management

    /// Delete a transaction
    func deleteTransaction(_ transaction: Transaction, modelContext: ModelContext) {
        modelContext.delete(transaction)
    }

    /// Update transaction category
    func updateCategory(for transaction: Transaction, to category: Category) {
        transaction.category = category
    }

    // MARK: - Helpers

    /// Format currency with Swiss locale
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CHF"
        formatter.locale = Locale(identifier: "de_CH")
        formatter.currencySymbol = "CHF "
        formatter.currencyGroupingSeparator = "'"
        formatter.currencyDecimalSeparator = "."

        let nsDecimal = amount as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "CHF 0.00"
    }
}
