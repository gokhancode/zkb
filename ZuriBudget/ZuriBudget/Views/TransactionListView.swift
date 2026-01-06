//
//  TransactionListView.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Full transaction list with filtering and sorting

import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedType: TransactionType?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                Color.canvasBackground(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filters
                    if !transactions.isEmpty {
                        filterBar
                            .swissGridPadding(2)
                    }

                    // Transaction list
                    if filteredTransactions.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: SwissTypography.baseUnit * 2) {
                                ForEach(filteredTransactions) { transaction in
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
                            .swissGridPadding(2)
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search transactions")
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: SwissTypography.baseUnit) {
            // Category filter
            Menu {
                Button("All Categories") {
                    selectedCategory = nil
                }

                Divider()

                ForEach(Category.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Label(category.rawValue, systemImage: category.icon)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(selectedCategory?.rawValue ?? "Category")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(.zkbBlue)
                .swissGridPadding(1)
                .background(Color.zkbBlue.opacity(0.1))
                .swissCornerRadius()
            }

            // Type filter
            Menu {
                Button("All Types") {
                    selectedType = nil
                }

                Divider()

                ForEach(TransactionType.allCases, id: \.self) { type in
                    Button(type.rawValue) {
                        selectedType = type
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.arrow.down.circle")
                    Text(selectedType?.rawValue ?? "Type")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(.zkbBlue)
                .swissGridPadding(1)
                .background(Color.zkbBlue.opacity(0.1))
                .swissCornerRadius()
            }

            Spacer()

            // Clear filters
            if selectedCategory != nil || selectedType != nil {
                Button {
                    selectedCategory = nil
                    selectedType = nil
                } label: {
                    Text("Clear")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.signalRed)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SwissTypography.baseUnit * 3) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)

            Text(transactions.isEmpty ? "No Transactions" : "No Results")
                .swissHeadline()

            Text(transactions.isEmpty
                ? "Import a ZKB statement to get started"
                : "Try adjusting your filters")
                .swissBody()
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .swissGridPadding(2)
    }

    // MARK: - Filtered Transactions

    private var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            // Search filter
            let matchesSearch = searchText.isEmpty ||
                transaction.details.localizedCaseInsensitiveContains(searchText)

            // Category filter
            let matchesCategory = selectedCategory == nil ||
                transaction.category == selectedCategory

            // Type filter
            let matchesType = selectedType == nil ||
                transaction.type == selectedType

            return matchesSearch && matchesCategory && matchesType
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

#Preview {
    TransactionListView()
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

    return TransactionListView()
        .modelContainer(container)
}
