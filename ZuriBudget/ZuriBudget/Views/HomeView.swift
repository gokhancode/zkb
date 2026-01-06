//
//  HomeView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Main dashboard view with Swiss grid layout

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @State private var viewModel = HomeViewModel()
    @State private var showImportSheet = false
    @State private var showAllTransactions = false
    @State private var showCharts = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.canvasBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SwissTypography.baseUnit * 3) {
                        // Balance header
                        balanceHeader

                        // Income/Expense summary
                        FinancialSummaryView(
                            income: viewModel.formattedIncome,
                            expenses: viewModel.formattedExpenses
                        )

                        // Recent transactions
                        if !transactions.isEmpty {
                            recentTransactionsSection
                        }

                        // Import prompt (if no transactions)
                        if transactions.isEmpty {
                            emptyState
                        }
                    }
                    .swissGridPadding(2)
                }

                // Floating action button
                floatingActionButton
            }
            .navigationTitle("ZüriBudget")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showCharts = true
                        } label: {
                            Label("Analytics", systemImage: "chart.xyaxis.line")
                        }

                        Button {
                            showAllTransactions = true
                        } label: {
                            Label("All Transactions", systemImage: "list.bullet")
                        }

                        Divider()

                        Button {
                            showImportSheet = true
                        } label: {
                            Label("Import Statement", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.zkbBlue)
                    }
                }
            }
            .sheet(isPresented: $showImportSheet) {
                PDFImportView { url in
                    showImportSheet = false
                    viewModel.handlePDFSelection(url: url)
                }
            }
            .sheet(isPresented: $viewModel.showDryRun) {
                if let result = viewModel.dryRunResult {
                    DryRunView(
                        parseResult: result,
                        onConfirm: {
                            viewModel.confirmTransactions(modelContext: modelContext)
                        },
                        onCancel: {
                            viewModel.cancelDryRun()
                        }
                    )
                }
            }
            .sheet(isPresented: $showAllTransactions) {
                TransactionListView()
            }
            .sheet(isPresented: $showCharts) {
                ChartsView()
            }
            .alert("Import Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .overlay {
                if viewModel.isImporting {
                    loadingOverlay
                }
            }
        }
        .onChange(of: transactions) { oldValue, newValue in
            viewModel.transactions = newValue
        }
        .onAppear {
            viewModel.transactions = transactions
        }
    }

    // MARK: - Balance Header

    private var balanceHeader: some View {
        VStack(spacing: SwissTypography.baseUnit) {
            Text("Total Balance")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textSecondary)
                .textCase(.uppercase)
                .kerning(0.5)

            Text(viewModel.formattedBalance)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.zkbBlue)
                .kerning(-1.0)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            // Balance indicator
            HStack(spacing: SwissTypography.baseUnit / 2) {
                Image(systemName: viewModel.balance >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(viewModel.balance >= 0 ? .emeraldGreen : .signalRed)

                Text(viewModel.balance >= 0 ? "Positive" : "Negative")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(viewModel.balance >= 0 ? .emeraldGreen : .signalRed)
            }
        }
        .swissGridPadding(3)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.zkbBlue.opacity(0.05),
                    Color.zkbBlue.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .swissCornerRadius()
    }

    // MARK: - Recent Transactions Section

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: SwissTypography.baseUnit * 2) {
            // Section header
            HStack {
                Text("Recent Transactions")
                    .swissHeadline()
                    .foregroundColor(.textPrimary)

                Spacer()

                Button {
                    showAllTransactions = true
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 15, weight: .medium))

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.zkbBlue)
                }
            }

            // Transaction list
            LazyVStack(spacing: SwissTypography.baseUnit * 2) {
                ForEach(Array(viewModel.recentTransactions.prefix(5))) { transaction in
                    TransactionRowView(transaction: transaction)
                        .swissCard()
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteTransaction(transaction)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SwissTypography.baseUnit * 3) {
            Image(systemName: "doc.text.below.ecg")
                .font(.system(size: 80))
                .foregroundColor(.textSecondary)

            VStack(spacing: SwissTypography.baseUnit) {
                Text("No Transactions Yet")
                    .swissHeadline()

                Text("Import your first ZKB statement to start tracking your finances")
                    .swissBody()
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showImportSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import Statement")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .swissGridPadding(2)
                .background(Color.zkbBlue)
                .swissCornerRadius()
            }
        }
        .swissGridPadding(4)
    }

    // MARK: - Floating Action Button

    private var floatingActionButton: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Button {
                    showImportSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.zkbBlue)
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        )
                }
                .swissGridPadding(2)
            }
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: SwissTypography.baseUnit * 2) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .zkbBlue))
                    .scaleEffect(1.5)

                Text("Parsing PDF...")
                    .swissBody()
                    .foregroundColor(.white)
            }
            .swissGridPadding(3)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
            )
        }
    }

    // MARK: - Actions

    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation {
            modelContext.delete(transaction)
        }
    }
}

// MARK: - Preview

#Preview("Empty State") {
    HomeView()
        .modelContainer(for: Transaction.self, inMemory: true)
}

#Preview("With Data") {
    let container = try! ModelContainer(
        for: Transaction.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    for transaction in Transaction.sampleTransactions {
        container.mainContext.insert(transaction)
    }

    return HomeView()
        .modelContainer(container)
}
