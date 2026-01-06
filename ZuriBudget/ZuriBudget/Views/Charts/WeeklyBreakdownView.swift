//
//  WeeklyBreakdownView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Swiss-style weekly spending bar chart

import SwiftUI
import Charts

struct WeeklyBreakdownView: View {
    let weeklyData: [(week: Date, amount: Decimal)]
    let formatCurrency: (Decimal) -> String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: SwissTypography.baseUnit * 2) {
            // Header
            HStack {
                Text("Weekly Spending")
                    .swissHeadline()
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("Last 4 Weeks")
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
            }

            if weeklyData.isEmpty {
                emptyState
            } else {
                // Bar Chart
                Chart(weeklyData, id: \.week) { data in
                    BarMark(
                        x: .value("Week", data.week, unit: .weekOfYear),
                        y: .value("Amount", Double(truncating: data.amount as NSNumber))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.zkbBlue, Color.zkbBlue.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4) // Minimal corner radius (Swiss style)
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(weekLabel(for: date))
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

                // Weekly Statistics
                HStack(spacing: SwissTypography.baseUnit * 2) {
                    StatCard(
                        label: "Average",
                        value: formatCurrency(averageWeekly),
                        color: .zkbBlue
                    )

                    StatCard(
                        label: "Highest",
                        value: formatCurrency(highestWeekly),
                        color: .signalRed
                    )

                    StatCard(
                        label: "Lowest",
                        value: formatCurrency(lowestWeekly),
                        color: .emeraldGreen
                    )
                }
            }
        }
        .swissGridPadding(2)
        .swissCard()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SwissTypography.baseUnit * 2) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)

            Text("No weekly data")
                .swissBody()
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .swissGridPadding(4)
    }

    // MARK: - Helpers

    private var averageWeekly: Decimal {
        guard !weeklyData.isEmpty else { return 0 }
        let total = weeklyData.reduce(Decimal(0)) { $0 + $1.amount }
        return total / Decimal(weeklyData.count)
    }

    private var highestWeekly: Decimal {
        weeklyData.map { $0.amount }.max() ?? 0
    }

    private var lowestWeekly: Decimal {
        weeklyData.map { $0.amount }.min() ?? 0
    }

    private func weekLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }

    private func formatShortCurrency(_ amount: Decimal) -> String {
        let value = Double(truncating: amount as NSNumber)
        if value >= 1000 {
            return String(format: "%.1fk", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}

// MARK: - Stat Card (reusable component)

struct StatCard: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: SwissTypography.baseUnit / 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textSecondary)
                .textCase(.uppercase)
                .kerning(0.5)

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    let now = Date()

    let sampleData: [(week: Date, amount: Decimal)] = [
        (calendar.date(byAdding: .weekOfYear, value: -3, to: now)!, 456.80),
        (calendar.date(byAdding: .weekOfYear, value: -2, to: now)!, 623.50),
        (calendar.date(byAdding: .weekOfYear, value: -1, to: now)!, 389.20),
        (now, 512.90)
    ]

    return WeeklyBreakdownView(
        weeklyData: sampleData,
        formatCurrency: { amount in
            "CHF \(amount)"
        }
    )
    .swissGridPadding(2)
}
