//
//  ZuriBudgetApp.swift
//  ZuriBudget
//
//  Created by Claude on 06.01.2026.
//
//  Main app entry point with SwiftData configuration

import SwiftUI
import SwiftData

@main
struct ZuriBudgetApp: App {

    // MARK: - SwiftData Configuration

    /// SwiftData model container
    /// Stores Transaction models with automatic persistence
    var modelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false // Persistent storage
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - App Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .preferredColorScheme(nil) // Respect system setting
        }
    }
}

// MARK: - Content View (Temporary Entry)

/// Temporary content view
/// Will be replaced with HomeView in next phase
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]

    var body: some View {
        NavigationStack {
            ZStack {
                // Swiss-style background
                Color.canvasBackground(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: SwissTypography.baseUnit * 3) {
                    // App branding
                    VStack(spacing: SwissTypography.baseUnit) {
                        Text("ZüriBudget")
                            .swissTitle()
                            .foregroundColor(.zkbBlue)

                        Text("Finance Tracker for ZKB Users")
                            .swissCaption()
                    }
                    .swissGridPadding(3)

                    // Status indicator
                    VStack(spacing: SwissTypography.baseUnit * 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.emeraldGreen)

                        Text("Core Models Ready")
                            .swissHeadline()

                        Text("\(transactions.count) transactions loaded")
                            .swissBody()
                            .foregroundColor(.textSecondary)
                    }

                    // System info
                    VStack(alignment: .leading, spacing: SwissTypography.baseUnit) {
                        InfoRow(label: "SwiftData", value: "Configured")
                        InfoRow(label: "PDF Parser", value: "Ready")
                        InfoRow(label: "Categories", value: "\(Category.allCases.count)")
                        InfoRow(label: "Design System", value: "Swiss Style")
                    }
                    .swissCard()
                    .swissGridPadding(2)

                    Spacer()
                }
                .swissGridPadding(2)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Views

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .swissBody()
                .foregroundColor(.textSecondary)

            Spacer()

            Text(value)
                .swissBody()
                .foregroundColor(.zkbBlue)
                .fontWeight(.semibold)
        }
        .swissGridPadding(1)
    }
}

// MARK: - Previews

#Preview {
    ContentView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
