//
//  CategoryChartView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Swiss-style category distribution pie chart

import SwiftUI
import Charts

struct CategoryChartView: View {
    let categoryData: [(category: Category, amount: Decimal)]
    let formatCurrency: (Decimal) -> String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: SwissTypography.baseUnit * 2) {
            // Header
            Text("Spending by Category")
                .swissHeadline()
                .foregroundColor(.textPrimary)

            if categoryData.isEmpty {
                emptyState
            } else {
                // Pie Chart
                Chart(categoryData, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", Double(truncating: item.amount as NSNumber)),
                        innerRadius: .ratio(0.5), // Donut chart
                        angularInset: 1.5 // Minimal spacing between segments
                    )
                    .foregroundStyle(categoryColor(for: item.category))
                    .opacity(0.9)
                }
                .frame(height: 200)
                .chartLegend(.hidden) // We'll create custom legend

                // Custom Legend (Swiss style - minimal, aligned)
                LazyVStack(spacing: SwissTypography.baseUnit) {
                    ForEach(Array(categoryData.prefix(5)), id: \.category) { item in
                        CategoryLegendRow(
                            category: item.category,
                            amount: formatCurrency(item.amount),
                            percentage: calculatePercentage(for: item.amount),
                            color: categoryColor(for: item.category)
                        )
                    }

                    if categoryData.count > 5 {
                        CategoryLegendRow(
                            category: .other,
                            amount: formatCurrency(remainingAmount),
                            percentage: calculatePercentage(for: remainingAmount),
                            color: Color.gray
                        )
                    }
                }
            }
        }
        .swissGridPadding(2)
        .swissCard()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SwissTypography.baseUnit * 2) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)

            Text("No spending data")
                .swissBody()
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .swissGridPadding(4)
    }

    // MARK: - Helpers

    private var totalAmount: Decimal {
        categoryData.reduce(0) { $0 + $1.amount }
    }

    private var remainingAmount: Decimal {
        categoryData.dropFirst(5).reduce(0) { $0 + $1.amount }
    }

    private func calculatePercentage(for amount: Decimal) -> String {
        let total = Double(truncating: totalAmount as NSNumber)
        let value = Double(truncating: amount as NSNumber)
        let percentage = (value / total) * 100
        return String(format: "%.0f%%", percentage)
    }

    private func categoryColor(for category: Category) -> Color {
        // Swiss-style: limited, functional color palette
        switch category {
        case .groceries:
            return Color.emeraldGreen
        case .transport:
            return Color.zkbBlue
        case .rent:
            return Color.signalRed
        case .utilities:
            return Color.zurichBlue
        case .healthcare:
            return Color.orange
        case .dining:
            return Color.pink
        case .shopping:
            return Color.purple
        case .insurance:
            return Color.teal
        case .salary:
            return Color.emeraldGreen
        case .entertainment:
            return Color.indigo
        case .education:
            return Color.cyan
        case .savings:
            return Color.mint
        case .other:
            return Color.gray
        }
    }
}

// MARK: - Legend Row

struct CategoryLegendRow: View {
    let category: Category
    let amount: String
    let percentage: String
    let color: Color

    var body: some View {
        HStack(spacing: SwissTypography.baseUnit) {
            // Color indicator
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            // Category icon
            Image(systemName: category.icon)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .frame(width: 20)

            // Category name
            Text(category.rawValue)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)

            Spacer()

            // Percentage
            Text(percentage)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textSecondary)
                .frame(width: 40, alignment: .trailing)

            // Amount
            Text(amount)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textPrimary)
                .frame(width: 120, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleData: [(category: Category, amount: Decimal)] = [
        (.groceries, 450.80),
        (.transport, 189.00),
        (.utilities, 145.00),
        (.dining, 325.50),
        (.shopping, 267.90)
    ]

    return CategoryChartView(
        categoryData: sampleData,
        formatCurrency: { amount in
            "CHF \(amount)"
        }
    )
    .swissGridPadding(2)
}
