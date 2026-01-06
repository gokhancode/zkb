//
//  ChartsViewModel.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  ViewModel for Charts - Processes transaction data for visualization

import Foundation
import SwiftUI

@Observable
final class ChartsViewModel {

    // MARK: - Properties

    var transactions: [Transaction] = []

    // MARK: - Category Data

    /// Spending by category (for pie chart)
    var categorySpending: [(category: Category, amount: Decimal)] {
        let grouped = Dictionary(grouping: transactions.filter { $0.type == .debit }) { $0.category }

        return grouped.map { category, transactions in
            let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
            return (category: category, amount: total)
        }
        .sorted { $0.amount > $1.amount }
    }

    /// Top 5 spending categories
    var topCategories: [(category: Category, amount: Decimal)] {
        Array(categorySpending.prefix(5))
    }

    // MARK: - Monthly Trend Data

    /// Spending by month (for line chart)
    var monthlySpending: [(month: Date, amount: Decimal)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions.filter { $0.type == .debit }) { transaction in
            calendar.startOfMonth(for: transaction.date)
        }

        return grouped.map { month, transactions in
            let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
            return (month: month, amount: total)
        }
        .sorted { $0.month < $1.month }
    }

    /// Income vs Expenses by month (for comparison chart)
    var monthlyComparison: [(month: Date, income: Decimal, expenses: Decimal)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfMonth(for: transaction.date)
        }

        return grouped.map { month, transactions in
            let income = transactions.filter { $0.type == .credit }
                .reduce(Decimal(0)) { $0 + $1.amount }
            let expenses = transactions.filter { $0.type == .debit }
                .reduce(Decimal(0)) { $0 + $1.amount }
            return (month: month, income: income, expenses: expenses)
        }
        .sorted { $0.month < $1.month }
    }

    // MARK: - Weekly Spending

    /// Last 4 weeks spending (for bar chart)
    var weeklySpending: [(week: Date, amount: Decimal)] {
        let calendar = Calendar.current
        let fourWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -4, to: Date()) ?? Date()

        let recentTransactions = transactions.filter { $0.date >= fourWeeksAgo && $0.type == .debit }

        let grouped = Dictionary(grouping: recentTransactions) { transaction in
            calendar.startOfWeek(for: transaction.date)
        }

        return grouped.map { week, transactions in
            let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
            return (week: week, amount: total)
        }
        .sorted { $0.week < $1.week }
    }

    // MARK: - Statistics

    /// Average daily spending
    var averageDailySpending: Decimal {
        let expenses = transactions.filter { $0.type == .debit }
        guard !expenses.isEmpty else { return 0 }

        let calendar = Calendar.current
        let dates = expenses.map { $0.date }
        guard let earliest = dates.min(),
              let latest = dates.max() else {
            return 0
        }

        let days = calendar.dateComponents([.day], from: earliest, to: latest).day ?? 1
        let totalSpending = expenses.reduce(Decimal(0)) { $0 + $1.amount }

        return totalSpending / Decimal(max(1, days))
    }

    /// Largest category by spending
    var largestCategory: (category: Category, amount: Decimal, percentage: Double)? {
        guard let top = categorySpending.first else { return nil }

        let totalSpending = categorySpending.reduce(Decimal(0)) { $0 + $1.amount }
        let percentage = (Double(truncating: top.amount as NSNumber) / Double(truncating: totalSpending as NSNumber)) * 100

        return (category: top.category, amount: top.amount, percentage: percentage)
    }

    // MARK: - Helpers

    /// Format currency
    func formatCurrency(_ amount: Decimal) -> String {
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

    /// Format percentage
    func formatPercentage(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
}

// MARK: - Calendar Extensions

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }

    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}
