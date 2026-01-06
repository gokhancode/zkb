//
//  ChartsView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Main charts and analytics view

import SwiftUI
import SwiftData

struct ChartsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @State private var viewModel = ChartsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.canvasBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SwissTypography.baseUnit * 3) {
                        if transactions.isEmpty {
                            emptyState
                        } else {
                            // Overview Stats
                            overviewStats

                            // Category Distribution
                            CategoryChartView(
                                categoryData: viewModel.categorySpending,
                                formatCurrency: viewModel.formatCurrency
                            )

                            // Income vs Expenses Trend
                            TrendChartView(
                                monthlyData: viewModel.monthlyComparison,
                                formatCurrency: viewModel.formatCurrency
                            )

                            // Weekly Breakdown
                            WeeklyBreakdownView(
                                weeklyData: viewModel.weeklySpending,
                                formatCurrency: viewModel.formatCurrency
                            )

                            // Insights
                            insightsSection
                        }
                    }
                    .swissGridPadding(2)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: transactions) { oldValue, newValue in
            viewModel.transactions = newValue
        }
        .onAppear {
            viewModel.transactions = transactions
        }
    }

    // MARK: - Overview Stats

    private var overviewStats: some View {
        VStack(alignment: .leading, spacing: SwissTypography.baseUnit) {
            Text("Overview")
                .swissHeadline()
                .foregroundColor(.textPrimary)

            HStack(spacing: SwissTypography.baseUnit * 2) {
                OverviewCard(
                    icon: "chart.pie",
                    label: "Categories",
                    value: "\(viewModel.categorySpending.count)",
                    color: .zkbBlue
                )

                OverviewCard(
                    icon: "calendar",
                    label: "Months",
                    value: "\(viewModel.monthlyComparison.count)",
                    color: .zurichBlue
                )

                OverviewCard(
                    icon: "chart.bar",
                    label: "Weeks",
                    value: "\(viewModel.weeklySpending.count)",
                    color: .emeraldGreen
                )
            }
        }
        .swissGridPadding(2)
        .swissCard()
    }

    // MARK: - Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: SwissTypography.baseUnit * 2) {
            Text("Insights")
                .swissHeadline()
                .foregroundColor(.textPrimary)

            // Average Daily Spending
            InsightRow(
                icon: "calendar.day.timeline.left",
                label: "Average Daily Spending",
                value: viewModel.formatCurrency(viewModel.averageDailySpending),
                color: .zkbBlue
            )

            // Largest Category
            if let largest = viewModel.largestCategory {
                InsightRow(
                    icon: largest.category.icon,
                    label: "Top Category: \(largest.category.rawValue)",
                    value: "\(viewModel.formatCurrency(largest.amount)) (\(viewModel.formatPercentage(largest.percentage)))",
                    color: .signalRed
                )
            }

            // Transaction Count
            InsightRow(
                icon: "list.bullet",
                label: "Total Transactions",
                value: "\(transactions.count)",
                color: .emeraldGreen
            )
        }
        .swissGridPadding(2)
        .swissCard()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SwissTypography.baseUnit * 3) {
            Spacer()

            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 80))
                .foregroundColor(.textSecondary)

            VStack(spacing: SwissTypography.baseUnit) {
                Text("No Analytics Yet")
                    .swissHeadline()

                Text("Import your first ZKB statement to see charts and insights")
                    .swissBody()
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .swissGridPadding(2)
    }
}

// MARK: - Overview Card

struct OverviewCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: SwissTypography.baseUnit) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.textPrimary)
                .kerning(-0.5)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .swissGridPadding(2)
        .background(Color(UIColor.secondarySystemBackground))
        .swissCornerRadius()
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: SwissTypography.baseUnit) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)

            Text(label)
                .swissBody()
                .foregroundColor(.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview

#Preview("With Data") {
    let container = try! ModelContainer(
        for: Transaction.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    for transaction in Transaction.sampleTransactions {
        container.mainContext.insert(transaction)
    }

    return ChartsView()
        .modelContainer(container)
}

#Preview("Empty") {
    ChartsView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
