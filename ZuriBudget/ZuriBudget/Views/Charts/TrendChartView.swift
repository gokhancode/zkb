//
//  TrendChartView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Swiss-style spending trend line chart

import SwiftUI
import Charts

struct TrendChartView: View {
    let monthlyData: [(month: Date, income: Decimal, expenses: Decimal)]
    let formatCurrency: (Decimal) -> String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: SwissTypography.baseUnit * 2) {
            // Header
            HStack {
                Text("Income vs Expenses")
                    .swissHeadline()
                    .foregroundColor(.textPrimary)

                Spacer()

                // Legend
                HStack(spacing: SwissTypography.baseUnit * 2) {
                    LegendItem(color: .emeraldGreen, label: "Income")
                    LegendItem(color: .signalRed, label: "Expenses")
                }
            }

            if monthlyData.isEmpty {
                emptyState
            } else {
                // Line Chart
                Chart {
                    // Income line
                    ForEach(monthlyData, id: \.month) { data in
                        LineMark(
                            x: .value("Month", data.month, unit: .month),
                            y: .value("Amount", Double(truncating: data.income as NSNumber))
                        )
                        .foregroundStyle(Color.emeraldGreen)
                        .lineStyle(StrokeStyle(lineWidth: 2)) // Thin lines (Swiss style)
                    }

                    // Expenses line
                    ForEach(monthlyData, id: \.month) { data in
                        LineMark(
                            x: .value("Month", data.month, unit: .month),
                            y: .value("Amount", Double(truncating: data.expenses as NSNumber))
                        )
                        .foregroundStyle(Color.signalRed)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.month(.abbreviated))
                                    .font(.system(size: 11))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.gridGray)
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(formatShortCurrency(Decimal(amount)))
                                    .font(.system(size: 11))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }

                // Statistics
                if let latest = monthlyData.last {
                    HStack(spacing: SwissTypography.baseUnit * 3) {
                        StatCard(
                            label: "Latest Income",
                            value: formatCurrency(latest.income),
                            color: .emeraldGreen
                        )

                        StatCard(
                            label: "Latest Expenses",
                            value: formatCurrency(latest.expenses),
                            color: .signalRed
                        )

                        StatCard(
                            label: "Difference",
                            value: formatCurrency(latest.income - latest.expenses),
                            color: latest.income >= latest.expenses ? .emeraldGreen : .signalRed
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
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)

            Text("No trend data")
                .swissBody()
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .swissGridPadding(4)
    }

    // MARK: - Helpers

    private func formatShortCurrency(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSNumber)
        if value >= 1000 {
            return String(format: "%.0fk", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}

// MARK: - Legend Item

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleData: [(month: Date, income: Decimal, expenses: Decimal)] = [
        (Calendar.current.date(from: DateComponents(year: 2026, month: 1))!, 7500, 3200),
        (Calendar.current.date(from: DateComponents(year: 2026, month: 2))!, 7500, 2800),
        (Calendar.current.date(from: DateComponents(year: 2026, month: 3))!, 7500, 3500),
    ]

    return TrendChartView(
        monthlyData: sampleData,
        formatCurrency: { amount in
            "CHF \(amount)"
        }
    )
    .swissGridPadding(2)
}
